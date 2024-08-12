% Sabemos cuáles son las herramientas requeridas para realizar una tarea de limpieza. 
% Además, para las aspiradoras se indica cuál es la potencia mínima requerida para la tarea en cuestión.
herramientasRequeridas(ordenarCuarto, [[aspiradora(100), escoba], trapeador, plumero]).
herramientasRequeridas(limpiarTecho, [escoba, pala]).
herramientasRequeridas(cortarPasto, [bordedadora]).
herramientasRequeridas(limpiarBanio, [sopapa, trapeador]).
herramientasRequeridas(encerarPisos, [lustradpesora, cera, aspiradora(300)]).

% 1. Agregar a la base de conocimientos la siguiente información:
% a. Egon tiene una aspiradora de 200 de potencia.
% b. Egon y Peter tienen un trapeador, Ray y Winston no.
% c. Sólo Winston tiene una varita de neutrones.
% d. Nadie tiene una bordeadora.
tiene(egon, aspiradora(200)).
tiene(egon, trapeador).
tiene(egon, plumero).
tiene(peter, trapeador).
tiene(peter, sopapa).
tiene(winston, varitaDeNeutrones).

% 2. Definir un predicado que determine si un integrante satisface la necesidad de una
% herramienta requerida. Esto será cierto si tiene dicha herramienta, teniendo en cuenta
% que si la herramienta requerida es una aspiradora, el integrante debe tener una con
% potencia igual o superior a la requerida.
% Nota: No se pretende que sea inversible respecto a la herramienta requerida.
satisfaceNecesidad(Integrante, aspiradora(Potencia)):-
    tiene(Integrante, aspiradora(PotenciaAspiradora)),
    PotenciaAspiradora >= Potencia.
satisfaceNecesidad(Integrante, Herramienta):-
    tiene(Integrante, Herramienta),
    Herramienta \= aspiradora(_).
% Punto 6
satisfaceNecesidad(Persona, ListaRemplazables):-
	member(Herramienta, ListaRemplazables),
	satisfaceNecesidad(Persona, Herramienta).

% 3. Queremos saber si una persona puede realizar una tarea, que dependerá de las herramientas que tenga. Sabemos que:
% - Quien tenga una varita de neutrones puede hacer cualquier tarea, independientemente de qué herramientas requiera dicha tarea.
% - Alternativamente alguien puede hacer una tarea si puede satisfacer la necesidad de todas las herramientas requeridas para dicha tarea.
puedeRealizarTarea(Persona, Tarea):-
    herramientasRequeridas(Tarea, _),
    tiene(Persona, varitaDeNeutrones).
puedeRealizarTarea(Persona, Tarea):-
    tiene(Persona, _),
    herramientasRequeridas(Tarea, Herramientas),
    forall(member(Herramienta, Herramientas), satisfaceNecesidad(Persona, Herramienta)).

% 4. Nos interesa saber de antemano cuanto se le debería cobrar a un cliente por un pedido
% (que son las tareas que pide). Para ellos disponemos de la siguiente información en la base de conocimientos:
% - tareaPedida/3: relaciona al cliente, con la tarea pedida y la cantidad de metros
% cuadrados sobre los cuales hay que realizar esa tarea.
% - precio/2: relaciona una tarea con el precio por metro cuadrado que se cobraría al cliente.
% Entonces lo que se le cobraría al cliente sería la suma del valor a cobrar por cada tarea,
% multiplicando el precio por los metros cuadrados de la tarea.

realizarPresupuesto(Cliente, Presupuesto):-
    tareaPedida(Cliente, _, _),
    findall(Precio, (tareaPedida(Cliente, Tarea, Metros), calcularPrecioTarea(Tarea, Metros, Precio)), Precios),
    sumlist(Precios, Presupuesto).

calcularPrecioTarea(Tarea, Metros, Precio):-
    precio(Tarea, PrecioTarea),
    Precio is (Metros * PrecioTarea).
% tareaPedida(Cliente, Tarea, MetrosCuadrados)
tareaPedida(pepito, ordenarCuarto, 20).
tareaPedida(pepito, limpiarBanio, 15).
tareaPedida(fulanito, encerarPisos, 25).
tareaPedida(fulanito, cortarPasto, 50).
tareaPedida(menganito, limpiarTecho, 10).
tareaPedida(carlitos, limpiarBanio, 40).
% precio(Tarea, PrecioPorMetroCuadrado) 
precio(ordenarCuarto, 20).
precio(limpiarBanio, 70).
precio(encerarPisos, 50).
precio(cortarPasto, 40).
precio(limpiarTecho, 35).

% 5. Finalmente necesitamos saber quiénes aceptarían el pedido de un cliente. Un
% integrante acepta el pedido cuando puede realizar todas las tareas del pedido y además está dispuesto a aceptarlo.
% Sabemos que Ray sólo acepta pedidos que no incluyan limpiar techos, Winston sólo acepta pedidos que paguen más de $500, Egon está dispuesto a aceptar 
% pedidos que no tengan tareas complejas y Peter está dispuesto a aceptar cualquier pedido.
% Decimos que una tarea es compleja si requiere más de dos herramientas. Además la limpieza de techos siempre es compleja.
aceptaPedidoDe(Integrante, Cliente):-
    puedeRealizarTodasLasTareas(Integrante, Cliente),
    estaDispuesto(Integrante, Cliente).

puedeRealizarTodasLasTareas(Integrante, Cliente):-
    tiene(Integrante, _),
    tareaPedida(Cliente, _, _),
    forall(tareaPedida(Cliente, Tarea, _), puedeRealizarTarea(Integrante, Tarea)).

estaDispuesto(ray, Cliente):-
    forall(tareaPedida(Cliente, Tarea, _), Tarea \= limpiarTecho).
estaDispuesto(winston, Cliente):-
    realizarPresupuesto(Cliente, Presupuesto),
    Presupuesto > 500.
estaDispuesto(egon, Cliente):-
    forall(tareaPedida(Cliente, Tarea, _), not(esCompleja(Tarea))).
estaDispuesto(peter, _).

esCompleja(Tarea):-
    herramientasRequeridas(Tarea, Herramientas),
    length(Herramientas, Cantidad),
    Cantidad > 2.
esCompleja(limpiarTecho).

% 6. Necesitamos agregar la posibilidad de tener herramientas reemplazables, que incluyan 2 herramientas de las que pueden tener los integrantes como 
% alternativas, para que puedan usarse como un requerimiento para poder llevar a cabo una tarea.
% a. Mostrar cómo modelarías este nuevo tipo de información modificando el hecho de herramientasRequeridas/2 para que ordenar un cuarto pueda
% realizarse tanto con una aspiradora de 100 de potencia como con una escoba, además del trapeador y el plumero que ya eran necesarios.
% b. Realizar los cambios/agregados necesarios a los predicados definidos en los puntos anteriores para que se soporten estos nuevos requerimientos de
% herramientas para poder llevar a cabo una tarea, teniendo en cuenta que para las herramientas reemplazables alcanza con que el integrante satisfaga la
% necesidad de alguna de las herramientas indicadas para cumplir dicho requerimiento.
% c. Explicar a qué se debe que esto sea difícil o fácil de incorporar.
