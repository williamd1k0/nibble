#ifndef KERNEL_H
#define KERNEL_H

#include <cstdint>
#include <vector>
#include <string>
#include <kernel/Process.hpp>
#include <kernel/Memory.hpp>

using namespace std;

// Simula o hardware do console e um kernel com
// seis chamadas de sistema. Três para gerenciar
// a memória e três para gerenciar processos.
class Kernel {
    // Memória para acesso direto aos dispositivos
    // Cada seção específica (joysticks, video, cart)
    // é implementada como uma extensão
    // da classe Memory
    vector <Memory*> ram;
    // Contém todos os processos carregados em memória
    // apenas um está em execução a cada instante (o último elemento do vetor)
    vector <Process*> processes;
    
public:
    Kernel();
    ~Kernel();

    // Loop principal do console. Atualiza o processo em execução e desenha a tela.
    void loop();

    // API do kernel
    // Acesso direto a memória
    // O acesso ao vídeo e áudio também é feito através de
    // writes e reads
    // Estas funções operam no vetor de ram, dividindo suas
    // chamadas em blocos unitários que podem ser executados
    // por um dos elementos de ram (dispositivos)
    uint64_t write(uint64_t, uint8_t*, uint64_t);
    uint64_t read(uint64_t, uint8_t*, uint64_t);
    uint64_t copy(uint64_t, uint64_t, uint64_t);
    // Gerenciamento de processos
    uint64_t exec(string&, vector<string>&);
    bool yield(uint64_t);
    void exit();
private:
    // Mapeia dispositivos para a memória, essencialmente
    // adicionando dispositivos ao vetor ram. Chamada pelo
    // construtor
    void createMemoryMap();
    void destroyMemoryMap();
};

#endif /* KERNEL_H */
