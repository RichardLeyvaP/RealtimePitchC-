

#include <string>

extern "C" {
    const char* stringFromCpp() {
        return "Hola desde C++ en Flutter!";
    }
}

// #include <iostream>
// #include <fstream>
// #include <vector>
// #include <cmath>

// using namespace std;

// struct WAVHeader {
//     char riff[4];
//     int overall_size;
//     char wave[4];
//     char fmt_chunk_marker[4];
//     int length_of_fmt;
//     short format_type;
//     short channels;
//     int sample_rate;
//     int byterate;
//     short block_align;
//     short bits_per_sample;
//     char data_chunk_header[4];
//     int data_size;
// };

// vector<short> readWavData(const string &filename, WAVHeader &header) {
//     ifstream file(filename, ios::binary);
//     file.read((char*)&header, sizeof(WAVHeader));
    
//     vector<short> samples(header.data_size / 2);
//     file.read((char*)samples.data(), header.data_size);
//     file.close();
//     return samples;
// }

// // FFT (Cooley-Tukey) para analizar frecuencias
// void fft(vector<complex<double>> &data) {
//     int n = data.size();
//     if (n <= 1) return;
    
//     vector<complex<double>> even(n/2), odd(n/2);
//     for (int i = 0; i < n / 2; i++) {
//         even[i] = data[i * 2];
//         odd[i] = data[i * 2 + 1];
//     }
//     fft(even);
//     fft(odd);
    
//     for (int i = 0; i < n / 2; i++) {
//         complex<double> t = polar(1.0, -2 * M_PI * i / n) * odd[i];
//         data[i] = even[i] + t;
//         data[i + n/2] = even[i] - t;
//     }
// }

// // Encuentra la frecuencia principal en el espectro
// double getPitch(const vector<short> &samples, int sampleRate) {
//     int n = samples.size();
//     vector<complex<double>> complexSamples(n);
//     for (int i = 0; i < n; i++) complexSamples[i] = complex<double>(samples[i], 0);
    
//     fft(complexSamples);
    
//     int peakIndex = 0;
//     double maxAmplitude = 0;
//     for (int i = 1; i < n / 2; i++) {
//         double amplitude = abs(complexSamples[i]);
//         if (amplitude > maxAmplitude) {
//             maxAmplitude = amplitude;
//             peakIndex = i;
//         }
//     }
    
//     return (double)peakIndex * sampleRate / n;
// }

// // Convierte una frecuencia en Hz a una nota musical
// string getNoteFromPitch(double frequency) {
//     string notes[] = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
//     if (frequency <= 0) return "Unknown";
    
//     int noteIndex = round(12 * log2(frequency / 440.0)) + 9;
//     int octave = noteIndex / 12;
//     return notes[noteIndex % 12] + to_string(octave);
// }

// extern "C" {
//     void analyzeWav(const char* filename) {
//         WAVHeader header;
//         vector<short> samples = readWavData(filename, header);
//         double pitch = getPitch(samples, header.sample_rate);
//         string note = getNoteFromPitch(pitch);
//         double duration = (double)samples.size() / header.sample_rate;
        
//         cout << "Pitch: " << pitch << " Hz" << endl;
//         cout << "Note: " << note << endl;
//         cout << "Duration: " << duration << " sec" << endl;
//     }
// }


