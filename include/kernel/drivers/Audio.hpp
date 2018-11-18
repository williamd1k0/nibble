#ifndef AUDIO_H
#define AUDIO_H

#include <kernel/Channel.hpp>
#include <kernel/Memory.hpp>
#include <SFML/Audio.hpp>

#define SND_CHANNELS        8
#define SND_MEMORY_LENGTH   512

class Audio : public Memory, public sf::SoundStream {
    // Samples
    const static unsigned int sampleCount;
    int16_t* samples;
    // Posição no layout de memória
    const uint64_t address;

	// Canais FM
	Channel *channels[SND_CHANNELS];

    // Registradores
    uint8_t *sndMemory;

    // Tick
	unsigned long nextTick, tickPeriod;
	unsigned long t;

    bool playing;
public:
    Audio(const uint64_t);
    ~Audio();

	string name();
    
    uint64_t write(const uint64_t, const uint8_t*, const uint64_t);
    uint64_t read(const uint64_t, uint8_t*, const uint64_t);

    uint64_t size();
    uint64_t addr();

    void exit();
private:
	// Sinal de clock para mudar os parâmetros da onda
    // chama uma callback no cart atual
	void tick();
	void calculateTickPeriod(const double);
	void calculateNextTick();

    // Prepara samples mixados
    void mix(int16_t*, unsigned int);

    bool onGetData(Chunk&);
    void onSeek(sf::Time);
};

#endif /* AUDIO_H */
