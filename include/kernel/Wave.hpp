#ifndef WAVE_H
#define WAVE_H

#define NIBBLE_WAVETABLE_SIZE 64

#include <cstdint>
#include <vector>

using namespace std;

class Wave {
public:
    int16_t table[NIBBLE_WAVETABLE_SIZE];

    Wave();

    const int16_t operator[](uint16_t) const;
private:
    const int16_t valueAt(uint8_t) const; 
};

#endif /* WAVE_H */
