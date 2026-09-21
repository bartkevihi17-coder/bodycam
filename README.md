# BODYCAM DEV

Prototype FPS/bodycam para Roblox feito em **Luau + Rojo**.

## Já implementado

- câmera travada em primeira pessoa;
- head bob e sway;
- roll lateral baseado no movimento;
- sprint com FOV dinâmico;
- agachar;
- HUD de bodycam com REC/data/hora;
- mapa graybox gerado automaticamente;
- iluminação noturna;
- G17 de protótipo;
- pente de 17 tiros + munição reserva;
- reload com R;
- recoil;
- raycast e dano validados no servidor.

## Controles

- **WASD**: movimento
- **Shift**: correr
- **Ctrl** ou **C**: agachar
- **Mouse 1**: atirar
- **R**: recarregar

## Estrutura

```text
src/
  client/
    BodycamController.client.luau
    GunController.client.luau
  server/
    Bootstrap.server.luau
    Combat.server.luau
  shared/
    Config.luau
default.project.json
```

## Conectar ao Roblox Studio

1. Clone este repositório no PC.
2. Instale o Rojo CLI e o plugin Rojo no Roblox Studio.
3. Abra um Baseplate no Studio.
4. No terminal, dentro deste repositório:

```bash
rojo serve
```

5. No Studio, abra o plugin Rojo e conecte ao servidor local.
6. Faça o sync.
7. Aperte **Play**.

A partir daí, alterações nos arquivos Luau podem ser sincronizadas direto para o Studio.
