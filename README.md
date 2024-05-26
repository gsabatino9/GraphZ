# GraphZ

## Integrantes
- Gonzalo Sabatino. Padrón 104609
- Alejandro Balladares. Padrón 101118
- Facundo Polech. Padrón 108652

## Objetivo del proyecto
El objetivo del proyecto es utilizar el lenguaje de programación [Zig](https://ziglang.org/), identificando fortalezas y debilidades del mismo, además de una apreciación de cada uno de los miembros del equipo por los features más relevantes que o bien se encuentran, o bien están faltantes en el lenguaje.

## Problema escogido
Para analizar el lenguaje, se llevan a cabo distintas implementaciones de un grafo:
- Utilizando un diccionario para indexar los nodos, y una lista para representar las adyacencias.
- Utilizando un diccionario para indexar los nodos, y un diccionario para indexar las adyacencias.
- Representando al mismo como una matriz de adyacencias.

Puesto que Zig es un lenguaje diseñado para realizar un código robusto y óptimo (comparable con C, C++ o Rust), se medirá la performance de las implementaciones a través de distintos programas (con parámetros constantes, con inputs de usuario, con archivos, etc), entendiendo qué mejoras ofrece el lenguaje.

Se utilizarán distintas estrategias para interactuar con memoria dinámica; se utilizarán distintas implementaciones de estructuras de datos similares (ej: un hashmap convencional vs un hashmap representado como array); etc.

## Pasos a seguir
1. [Realizado] Familiarización con el lenguaje y sus herramientas.
2. [En curso] Implementación de los grafos.
3. Escoger herramientas / mecanismos para realizar benchmarks.
4. Analizar y comparar la performance de las implementaciones en un programa io simple.
5. Analizar y comparar la performance de las implementaciones en un programa con archivos de distintos tamaños (llegando a simular una red de millones de nodos).
6. [Opcional] Analizar y comparar la performance de las implementaciones en un servidor con interacción con múltiples clientes.
