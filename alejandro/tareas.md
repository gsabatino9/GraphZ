## Tareas

## Semana 20/05
Realizada la implementación de la matriz con un ArrayList de nodos. Los nodos son un struct que tiene un arrayList para las adyacencias y el valor del label. Ambos con sus respectivos métodos y además pruebas básicas para corroborar su correcto funcionamiento. 

## Semana 27/05
Refactorizar el código para que cumpla los estandares de zig.
Agregar una construcción de grafo a traves de un archivo.

## Semana 03/06
Revisar rendimiento de mi implementación y (de ser posible) variar la estructura y los allocators para comparar

Nodo :   gregarNodo(self: *Self): solo hace un append así que es O(1) si hay lugar al final de la lista y O(n) si hay que realocar

    iniciarNodo(self: *Self, tam: u32): O(n) ya que agrega ceros según el tamaño actual del grafo

    agregarAdyacencia(self: *Self, pos: usize) O(1): ya que es pararse en una posición ya definida y cambiar el valor

    deinit(self: *Self) definir

Grafo: 
    pub fn nodeExists(self: *Self, node: []const u8):  O(n) ya que recorre toda la lista de nodos buscando una coincidencia.

    pub fn addNode(self: *Self, node: []const u8): O(n) ya que hace un llamado a "nodeExists", luego otro O(n) ya que llama a "iniciarNodo" y por último otro O(n) ya que tiene que recorrer todos los nodos para agregar una nueva adyacencia. En total O(3n) = O(n)

    pub fn addEdge(self: *Self, node1: []const u8, node2: []const u8): O(2n) ya que hace dos llamado a "nodeExists", luego otro O(2n) ya que tengo que recorrer todos los nodos para encontrar sus posiciones en el grafo. Por último hago dos agregarAdyacencia que son O(1) por lo que en total sería O(4n) = O(n)

    pub fn edgeExists(self: *Self, node1: []const u8, node2: []const u8): (2n) ya que hace dos llamado a "nodeExists", luego otro O(n) ya que tengo que recorrer todos los nodos para encontrar la posicion del segundo en el grafo. Por último otro O(n) ya que hago otro recorrido al grafo para encontrar el primer nodo y luego verifico que la arista exista en O(1). En total es O(4n) = O(n)

    pub fn deleteNode(self: *Self, node1: []const u8):  O(n) ya que hace un llamado a "nodeExists", luego otro O(n) ya que tengo que recorrer todo el grafo para encontrar la posicion del nodo a eliminar. Al final vuelvo a recorrer todos los nodos (O(n)) para eliminar el nodo y en cada iteración uso la función orderedRemove que tendrá que realocar todos los elementos a la derecha del eliminado, en el peor escenario O(n) por lo que me quedaría el tiempo total sería O(n) + O(n^2) = O(n^2)

    pub fn deleteEdge(self: *Self, node1: []const u8, node2: []const u8): O(2n) ya que hace dos llamado a "nodeExists", luego otro O(2n) ya que tengo que recorrer todos los nodos para encontrar sus posiciones en el grafo. Por último hago dos acessos a las posiciones que son O(1) por lo que en total sería O(4n) = O(n)

    Estadistica de Perf:
    Performance counter stats for 'zig run main.zig':

         12.371,95 msec task-clock                       #    0,990 CPUs utilized             
             2.599      context-switches                 #  210,072 /sec                      
                11      cpu-migrations                   #    0,889 /sec                      
         1.296.006      page-faults                      #  104,754 K/sec                     
   <not supported>      cycles                                                                
   <not supported>      instructions                                                          
   <not supported>      branches                                                              
   <not supported>      branch-misses                                                         

      12,494373457 seconds time elapsed

       9,048919000 seconds user
       3,318873000 seconds sys
