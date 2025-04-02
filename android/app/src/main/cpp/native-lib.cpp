
#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <complex>
#include <string>
#include <cstring>
#include <cstdlib>

using namespace std;

struct WAVHeader {
    char riff[4];
    int overall_size;
    char wave[4];
    char fmt_chunk_marker[4];
    int length_of_fmt;
    short format_type;
    short channels;
    int sample_rate;
    int byterate;
    short block_align;
    short bits_per_sample;
    char data_chunk_header[4];
    int data_size;
};

struct PitchResult {
    double pitch;
    double duration;
    char* note;
};

string getNoteFromPitch(double frequency) {
    if (frequency <= 0) return "Unknown";
    
    const string notes[] = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
    double A4 = 440.0;
    double C0 = A4 * pow(2, -4.75);
    int semi_tones = round(12 * log2(frequency / C0));
    int octave = semi_tones / 12;
    int note_index = semi_tones % 12;
    
    return notes[note_index] + to_string(octave);
}

void fft(vector<complex<double>>& data) {
    int n = data.size();
    if (n <= 1) return;
    
    vector<complex<double>> even(n / 2), odd(n / 2);
    for (int i = 0; i < n / 2; i++) {
        even[i] = data[i * 2];
        odd[i] = data[i * 2 + 1];
    }
    fft(even);
    fft(odd);
    
    for (int i = 0; i < n / 2; i++) {
        complex<double> t = polar(1.0, -2 * M_PI * i / n) * odd[i];
        data[i] = even[i] + t;
        data[i + n / 2] = even[i] - t;
    }
}

double getPitch(const vector<short>& samples, int sampleRate) {
    int n = samples.size();
    vector<complex<double>> complexSamples(n);
    for (int i = 0; i < n; i++) {
        complexSamples[i] = complex<double>(samples[i], 0);
    }
    
    fft(complexSamples);
    
    int peakIndex = 0;
    double maxAmplitude = 0;
    for (int i = 1; i < n / 2; i++) {
        double amplitude = abs(complexSamples[i]);
        if (amplitude > maxAmplitude) {
            maxAmplitude = amplitude;
            peakIndex = i;
        }
    }
    
    return (double)peakIndex * sampleRate / n;
}

extern "C" {
    PitchResult* analyzeWav(const char* filePath, int* resultCount) {
        cout << "Intentando abrir: " << filePath << endl;
        
        WAVHeader header;
        ifstream file(filePath, ios::binary);
        if (!file) {
            cerr << "Error al abrir el archivo WAV." << endl;
            *resultCount = 0;
            return nullptr;
        }
        
        file.read(reinterpret_cast<char*>(&header), sizeof(WAVHeader));
        cout << "Tamaño de datos WAV: " << header.data_size << endl;
        
        if (header.data_size <= 0) {
            cerr << "Archivo WAV no contiene datos válidos" << endl;
            *resultCount = 0;
            return nullptr;
        }

        vector<short> samples(header.data_size / 2);
        file.read(reinterpret_cast<char*>(samples.data()), header.data_size);
        file.close();

        cout << "Muestras leídas: " << samples.size() << endl;
        
        int sampleRate = header.sample_rate;
        int blockSize = 1024;  // Tamaño de bloque en muestras
        int numBlocks = samples.size() / blockSize;
        *resultCount = numBlocks;
        
        vector<PitchResult> resultList;
        string prevNote = "";
        double accumulatedDuration = 0;
        double prevPitch = -1;
        
        for (int i = 0; i < numBlocks; i++) {
            vector<short> block(samples.begin() + i * blockSize, 
                              samples.begin() + (i + 1) * blockSize);
            double pitch = getPitch(block, sampleRate);
            double duration = blockSize / (double)sampleRate;
            string noteStr = getNoteFromPitch(pitch);
            
            // Agregamos cada pitch encontrado como un resultado
            PitchResult result;
            result.note = (char*)malloc(noteStr.length() + 1);
            strcpy(result.note, noteStr.c_str());
            result.pitch = pitch;
            result.duration = duration;
            resultList.push_back(result);
        }
        
        // Copiamos los resultados finales al arreglo de salida
        *resultCount = resultList.size();
        PitchResult* results = (PitchResult*)malloc(*resultCount * sizeof(PitchResult));
        for (int i = 0; i < *resultCount; i++) {
            results[i] = resultList[i];
        }
        
        return results;
    }
    
    void freeResults(PitchResult* results, int count) {
        if (!results) return;
        
        for (int i = 0; i < count; i++) {
            if (results[i].note) {
                free(results[i].note);
            }
        }
        free(results);
    }
}

