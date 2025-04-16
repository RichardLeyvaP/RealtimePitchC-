#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <complex>
#include <string>
#include <cstring>
#include <cstdlib>
#include <exception>
#include <cstdio>  // Para snprintf
#include <memory>  // Para unique_ptr

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
    char* note;  // Mantenemos char* para compatibilidad con malloc/free
    double startTime;
    double amplitude;
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

// Tolerancias configurables
//const double SEMITONE_TOLERANCE = 0.5; // ±0.5 semitonos
//const double TIME_TOLERANCE = 0.2;     // ±100ms
//const double MIN_AMPLITUDE = 0.1;      // Umbral mínimo de amplitud

// Función para calcular la diferencia en semitonos entre dos frecuencias
double semitoneDifference(double freq1, double freq2) {
    if (freq1 <= 0 || freq2 <= 0) return 100.0; // Valor alto para frecuencias inválidas
    return 12 * log2(freq2 / freq1);
}

extern "C" {

    __attribute__((visibility("default")))
    // const char* comparePitches(PitchResult* background, int bgCount, 
    //                          PitchResult* recorded, int recCount) {
        
    //     // Buffer para el resultado (evitamos retornar strings temporales)
    //     static char resultBuffer[256];
        
    //     try {
    //         if (recCount == 0) {
    //             snprintf(resultBuffer, sizeof(resultBuffer), "No hay voz detectada");
    //             return resultBuffer;
    //         }
    //         if (bgCount == 0) {
    //             snprintf(resultBuffer, sizeof(resultBuffer), "No hay música de fondo");
    //             return resultBuffer;
    //         }

    //         int matches = 0;
    //         int totalComparisons = 0;
    //         double totalDeviation = 0.0;

    //         // Comparación por ventanas de tiempo
    //         for (int i = 0; i < recCount; i++) {
    //             if (recorded[i].note == nullptr) continue;
                
    //             for (int j = 0; j < bgCount; j++) {
    //                 if (background[j].note == nullptr) continue;
                    
    //                 if (abs(background[j].startTime - recorded[i].startTime) <= TIME_TOLERANCE) {
    //                     totalComparisons++;
    //                     double diff = semitoneDifference(background[j].pitch, recorded[i].pitch);
    //                     totalDeviation += abs(diff);
                        
    //                     if (abs(diff) < SEMITONE_TOLERANCE) {
    //                         matches++;
    //                     }
    //                 }
    //             }
    //         }

    //         if (totalComparisons == 0) {
    //             snprintf(resultBuffer, sizeof(resultBuffer), "No hay coincidencias temporales");
    //             return resultBuffer;
    //         }

    //         double matchPercentage = (matches * 100.0) / totalComparisons;
    //         double avgDeviation = totalDeviation / totalComparisons;

    //         // Evaluación basada en los resultados
    //         if (matchPercentage >= 80 && avgDeviation < 0.3) {
    //             snprintf(resultBuffer, sizeof(resultBuffer), "Afinado");
    //         } else if (matchPercentage >= 50 || avgDeviation < 0.7) {
    //             snprintf(resultBuffer, sizeof(resultBuffer), "Mas o menos");
    //         } else {
    //             snprintf(resultBuffer, sizeof(resultBuffer), "Desafinado");
    //         }
            
    //         return resultBuffer;

    //     } catch (const std::exception& e) {
    //         snprintf(resultBuffer, sizeof(resultBuffer), "Error en comparación");
    //         return resultBuffer;
    //     } catch (...) {
    //         snprintf(resultBuffer, sizeof(resultBuffer), "Error desconocido");
    //         return resultBuffer;
    //     }
    // }

// Copia de tu función para test
const char* comparePitches(PitchResult* background, int bgCount,
    PitchResult* recorded, int recCount, int nivel) {

    static char resultBuffer[256];

    try {
        if (recCount == 0) {
            snprintf(resultBuffer, sizeof(resultBuffer), "No hay voz detectada");
            return resultBuffer;
        }
        if (bgCount == 0) {
            snprintf(resultBuffer, sizeof(resultBuffer), "No hay música de fondo");
            return resultBuffer;
        }

        // Parámetros según nivel
        double semitoneThreshold;
        double avgDeviationThreshold;
        double matchPercentageThreshold;

        switch (nivel) {
        case 1: // Fácil
            semitoneThreshold = 1.0;
            avgDeviationThreshold = 1.0;
            matchPercentageThreshold = 30.0;
            break;
        case 2: // Intermedio
            semitoneThreshold = 0.5;
            avgDeviationThreshold = 0.7;
            matchPercentageThreshold = 50.0;
            break;
        case 3: // Profesional
            semitoneThreshold = 0.3;
            avgDeviationThreshold = 0.3;
            matchPercentageThreshold = 80.0;
            break;
        default: // Por defecto, usar intermedio
            semitoneThreshold = 0.5;
            avgDeviationThreshold = 0.7;
            matchPercentageThreshold = 50.0;
            break;
        }

        int matches = 0;
        int totalComparisons = 0;
        double totalDeviation = 0.0;

        for (int i = 0; i < recCount; i++) {
            if (recorded[i].note == nullptr) continue;

            for (int j = 0; j < bgCount; j++) {
                if (background[j].note == nullptr) continue;

                if (abs(background[j].startTime - recorded[i].startTime) <= 0.2) {
                    totalComparisons++;
                    double diff = semitoneDifference(background[j].pitch, recorded[i].pitch);
                    totalDeviation += abs(diff);
                    printf("Comparando: Fondo %.2f Hz vs Grabado %.2f Hz -> %.3f semitonos\n",
                        background[j].pitch, recorded[i].pitch, diff);

                    if (abs(diff) < semitoneThreshold) {
                        matches++;
                    }
                }
            }
        }

        if (totalComparisons == 0) {
            snprintf(resultBuffer, sizeof(resultBuffer), "No hay coincidencias temporales");
            return resultBuffer;
        }

        double matchPercentage = (matches * 100.0) / totalComparisons;
        double avgDeviation = totalDeviation / totalComparisons;
        // Imprimir para depuración
        printf("Matches: %d\n", matches);
        printf("Total Comparisons: %d\n", totalComparisons);
        printf("Match Percentage: %.2f%%\n", matchPercentage);
        printf("Average Deviation: %.3f semitonos\n", avgDeviation);

        if (matchPercentage >= matchPercentageThreshold && avgDeviation < avgDeviationThreshold) {
            snprintf(resultBuffer, sizeof(resultBuffer), "Afinado");
        }
        else if (matchPercentage >= matchPercentageThreshold / 2 || avgDeviation < avgDeviationThreshold * 1.5) {
            snprintf(resultBuffer, sizeof(resultBuffer), "Más o menos");
        }
        else {
            snprintf(resultBuffer, sizeof(resultBuffer), "Desafinado");
        }

        return resultBuffer;
    }
    catch (...) {
        snprintf(resultBuffer, sizeof(resultBuffer), "Error en comparación");
        return resultBuffer;
    }
}





    __attribute__((visibility("default")))
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
        
        for (int i = 0; i < numBlocks; i++) {
            vector<short> block(samples.begin() + i * blockSize, 
                              samples.begin() + (i + 1) * blockSize);
            
            // Calcular amplitud promedio del bloque
            double amplitude = 0.0;
            for (short sample : block) {
                amplitude += abs(sample);
            }
            amplitude /= blockSize;
            
            double pitch = getPitch(block, sampleRate);
            double duration = blockSize / (double)sampleRate;
            double startTime = i * duration;
            string noteStr = getNoteFromPitch(pitch);
            
            // Asignar memoria para la nota
            char* noteCopy = (char*)malloc(noteStr.length() + 1);
            if (noteCopy == nullptr) {
                cerr << "Error asignando memoria para nota" << endl;
                continue;
            }
            strncpy(noteCopy, noteStr.c_str(), noteStr.length() + 1);
            
            PitchResult result;
            result.pitch = pitch;
            result.duration = duration;
            result.note = noteCopy;
            result.startTime = startTime;
            result.amplitude = amplitude;
            
            resultList.push_back(result);
        }
        
        // Copiamos los resultados finales al arreglo de salida
        *resultCount = resultList.size();
        PitchResult* results = (PitchResult*)malloc(*resultCount * sizeof(PitchResult));
        if (results == nullptr) {
            cerr << "Error asignando memoria para resultados" << endl;
            *resultCount = 0;
            return nullptr;
        }
        
        for (int i = 0; i < *resultCount; i++) {
            results[i] = resultList[i];
        }
        
        return results;
    }
    
    __attribute__((visibility("default")))
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