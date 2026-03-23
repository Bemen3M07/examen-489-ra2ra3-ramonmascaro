# EXAMEN · MÒDUL 489

## Programació de Dispositius Mòbils i Multimèdia

**Unitats Formatives:** RA2 i RA3  
**Curs:** 2n DAM · Videojocs  
**Data:** ____23/03/2026____  
**Durada:** 2 hores  

**Alumne/a:** _____Ramon Mascaró___________________  
**Grup:** ___________2n DAM__________________________________  

---

## Posada en marxa de l'entorn

Consulta el fitxer **`README.md`** del projecte per a les instruccions completes d'instal·lació i arrencada (Node.js, servidor mock i Flutter).

---

> **Instruccions generals**
>
> - Respon cada pregunta en l'espai indicat (substitueix el text `[Escriu la teva resposta aquí]`).
> - Per a la part de codi, escriu directament en bloc `dart`. No és necessari que el codi compili, però ha de reflectir coneixement real de Flutter/Dart.
> - Tens el codi dels projectes **Cars** i **Phone** com a referència en el teu ordinador. **No pots accedir a internet** durant l'examen.
> - Desa el fitxer i lliura'l amb el nom: `EXAMEN_M489_[el_teu_nom].md`
> - Fes commit i push del .md modificat i de tots els arxius que hagis modificat

---

## BLOC 1 · ARQUITECTURA I CICLE DE VIDA *(RA 2)*

### Pregunta 1.1 – Comunicació entre Widgets *(12 punts)*

Al projecte **Cars**, el widget `CarsPage` gestiona el número de pàgina actual (`_currentPage`) i el passa a `CarsList1`. El widget `ButtonPanel` conté els botons "Anterior" i "Següent".

**a)** A `cars_page.dart`, el widget utilitza el mètode `setState` per gestionar la paginació. Explica:

- Quina és la funció de `setState` i per què cridar-lo fa que la UI es torni a dibuixar.
- Per quin motiu `_loadPage()` fa servir dos crides a `setState` separades (una a l'inici i una al final) en lloc d'una sola.

**Resposta:**

```
Funcion setstate:

es el mecanismo que tiene flutter para avisar al FW de que el estado de un widget stateful ha canviado y se tiene que redibujar la UI.
Cunado se llama a setState el widget se marca como sucio y se re ejecuta el build para reconstruir eñ widget con los nuevos valores del estado.

Motivo dos llamadas a setState:

La primera llamada al inicio hace que la UI reconstruya el estado al instante mostrando el indicador de carga minetras espera la respuesta de la API, si no se llamara al inicio el usuario no tendria la sensacion de carga.

La segunda llamada se hace al final para actualizar _cas y pone isLoading = false una vez han llegado los datos, asi la UI se reconstruye con los datos (osea, lista de coches) que han llegado de la API (o el error si hay) y se deja de mostrar la animacion de carga. 

```

---

### Pregunta 1.2 – Cicle de vida d'un widget amb recursos *(13 punts)*

Al projecte **Camera**, el widget `CameraScreen` utilitza un `CameraController` per gestionar la càmera del dispositiu. Aquest controlador ocupa recursos del sistema (càmera, memòria) i cal alliberar-los correctament.

**a)** Quin mètode del cicle de vida de `State` s'usa a `CameraScreen` per alliberar el `CameraController` quan el widget és destruït? Escriu com es fa i explica per quina raó és imprescindible cridar-lo.

**Resposta:**

```
El metodo del ciclo de vida de state que se usa dispose() que pertenece a la clase State.


El mètode del cicle de vida que s'usa per alliberar el CameraController és
dispose(), que pertany a la classe State.

Se haria asi:

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

Es necesario llamarlo porque el cameraController gesiona recursos del OS como la camara o la memoria, si no se usa el cameraController una vez se cierre la camara quedará ocupada en segundo plano y no se podra usar por otras apps o otras funciones de la propia app ademas de ocupar una memoria innecesaria. Si se usa el _controller.dispose() se mata el proceso al acabar de usar el widget que usa la camara y entonces queda libre.

```

---

**b)** El `CameraController` s'inicialitza de forma asíncrona a `initState()` i el resultat es guarda a `_initializeControllerFuture`. Respon les preguntes següents:

- Per quin motiu no es pot fer `await` directament a `initState()`?
- Quina millora aporta a l'usuari usar `FutureBuilder` en lloc de bloquejar el fil?
- Com treballen junts `_initializeControllerFuture` i `FutureBuilder`?

**Resposta:**

```
- Per quin motiu no es pot fer `await` directament a `initState()`?

No se puede usar el await directamente porque initState es un metodo sincrono que tiene que devolver un void instantaneamente para despues llamar al build y pintar el primer estado del widget. Si se pusiera un await sera como convertirlo en un metodo asincrono y no se sabria cuando se ha acabado de iniciar el widget para pintarlo.


- Quina millora aporta a l'usuari usar `FutureBuilder` en lloc de bloquejar el fil?

Usar el FutureBuilder permite que la UI no se quede congelada mientras se espera que el future se complete, asi el usuario ve una animacion de carga mientras se inicia en segundo plano el proceso hasta que ya esta preparado. 

- Com treballen junts `_initializeControllerFuture` i `FutureBuilder`?

En el initState se guarda el future que devuelve el _controller.initialize() en _initializeControllerFuture, y en build() se pasa ese future al FutureBuilder. Entonces el FutureBuilder sobrescribe al Future y reconstruye el widget cada vez que cambia el estado del Future. 

```

---

## BLOC 2 · COMUNICACIÓ, PERSISTÈNCIA I PROVES *(RA 2 — 35 punts)*

### Pregunta 2.1 – Consum d'API i robustesa *(18 punts)*

Analitza el mètode `getCarsPage(int page, int limit)` de `car_http_service.dart`.

Què passaria si el servidor de l'API trigués 60 segons a respondre? L'aplicació quedaria bloquejada per a l'usuari? Per què? Escriu com implementaries un *timeout* de 10 segons a la petició HTTP.

**Resposta:**

```dart
// Escriu la modificació al getCarsPage aquí:
Future<List<CarsModel>> getCarsPage(int page, int limit) async {
  final offset = (page - 1) * limitt;
  final uri = _buildUri('/v1/cars', {'limit': '$limit', 'offset': '$offset'});

  try {
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return CarsModel.listFromJsonString(response.body);
    } else {
      throw Exception('Error');
    }
  } on TimeoutException {
    throw Exception('La peticion ha suprrado los 10s');
  } catch (e) {
    throw Exception('Error');
  }
}
```
Si el server tardara 60 segundos en responder la peticion se quedaria congelada hasta que el server respondiera. La app no deberia quedarse bloqueada porque al ser una funcion asincronia se quedaria mostrando la animacion de carga hasta que le llegara una respuesta.
La app se quedaría indefinidamente en carga hasta una respuesta lo que daria la sensacion de que la app se ha quedado bloqueada.

---

### Pregunta 2.2 – Models de dades  *(17 punts)*

Analitza el constructor `factory CarsModel.fromMapToCarObject(Map<String, dynamic> json)` de `car_model.dart`.

**a)** Imagina que l'API retorna per error el camp `year` com a `String` en lloc d'`int` (per exemple, `"2021"` en lloc de `2021`). El codi actual fallaria. Escriu com resoldries el problema.

**Resposta:**

```
Si la api devolviera por ejemplo yerar como string una solucion seria hacer primero un filtrado para saber si la respuesta es string o no y asignarle valor 0 en caso de que si lo sea. Y si ya es un init se comprueba que no sea nulo en cuyo caso tambien se le asignaria 0.

Algo asi:

  year: json['year'] is String
      ? int.tryParse(json['year'] as String) ?? 0
      : (json['year'] as int? ?? 0),


```

---

**b)** Al fitxer `class_model_test.dart`, el test utilitza un `const jsonString` amb un JSON escrit a mà en lloc de fer una petició real a l'API de RapidAPI. Explica per quin motiu és millor simular el JSON en un test unitari.

**Resposta:**

```
Los motivos principales son los siguientes

El primero es para aislar de dependencias externas, es decir, si se queire provar un codigo en concreto se usa un json a mano para no depender de que la api o algo externo pueda dar un error.

Tambien un motivo puede ser que al tener el json a mano se puede recrear la ejecucion exactamente igual mas de una vez para comprobar donde puede haber un error.

Además el hecho de no depender de una API tambien hace que la velocidad del test sea mas rapida y no dependa de la red o la propia API.

```

---

## BLOC 3 · IMPLEMENTACIÓ PRÀCTICA *(RA 3 — 30 punts)*

### Exercici – Widget de detall amb dades remotes

Imagina que volem crear una pantalla de detall per a cada cotxe del projecte Cars. Implementa el mètode `build` d'un widget `StatelessWidget` anomenat `CarDetailPage` que compleixi els requisits següents:

1. Rep un paràmetre `final CarsModel car` al constructor.
2. Mostra el **make** i el **model** del cotxe com a títol destacat (`Text` amb estil gran i negreta).
3. Mostra una **icona diferent** depenent del `type` del cotxe:
   - Si el `type` és `'SUV'`, mostra `Icons.directions_car`.
   - Per qualsevol altre tipus, mostra `Icons.car_rental`.
4. Afegeix un botó `ElevatedButton` que, quan es premi, mostri un `SnackBar` amb el text: `"Cotxe seleccionat: [make] [model]"`.

```dart
// Escriu el teu codi aquí:

class CarDetailPage extends StatelessWidget {
    final CarsModel car;

    const CarDetailPage({super.key, required this.car});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('${car.make} ${car.model}')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${car.make} ${car.model}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                car.type == 'SUV' ? Icons.directions_car : Icons.car_rental,
                size: 64,
              ),
              const SizedBox(height: 8),
              Text('Tipo: ${car.type}'),
              Text('Año: ${car.year}'),
              Text('Color: ${car.color}'),
              Text('Ciudad: ${car.city}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cohce seleccionado: ${car.make} ${car.model}'),
                    ),
                  );
                },
                child: const Text('Seleccionar coche'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Otros coches:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<CarsModel>>(
                  future: CarHttpService().getCarsPage(1, 5),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    final cars = snapshot.data!;
                    return ListView.builder(
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        return ListTile(title: Text(cars[index].make));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
```

---

**Ampliació (nivell Expert):** Afegeix un `FutureBuilder` que cridi al mètode `CarHttpService().getCarsPage(1, 5)` i mentre espera les dades mostri un `CircularProgressIndicator`. Quan les dades estiguin llestes, mostra un `ListView.builder` amb el `make` de cada cotxe. Si hi hagués un error, mostra un `Text` en color vermell amb el missatge de l'error.

```dart
//Escriu la teva ampliació aquí:
Esa funcion ya esta integrada en la clase pero corresponde a esta parte concretamente:

child: FutureBuilder<List<CarsModel>>(
  future: CarHttpService().getCarsPage(1, 5),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Text(
        'Error: ${snapshot.error}',
        style: const TextStyle(color: Colors.red),
      );
    }
    final cars = snapshot.data!;
    return ListView.builder(
      itemCount: cars.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(cars[index].make));
      },
    );
  },
),
```

---

## BLOC 4 · EXTENSIÓ DEL SERVEI HTTP *(RA 2 — 10 punts)*

### Exercici 4.1 – Mètode parametritzat a `CarHttpService` *(10 punts)*

El servidor mock local té disponible un  endpoint de cerca:

```
GET http://localhost:8080/v1/cars/search?make=Toyota&model=Corolla
```

- El paràmetre `make` filtra per marca (coincidència parcial, insensible a majúscules).
- El paràmetre `model` filtra per model (coincidència parcial, insensible a majúscules).
- Tots dos paràmetres són opcionals: si no s'envien, retorna tots els cotxes.

Exemples vàlids:

- `/v1/cars/search?make=Toyota` → tots els Toyota
- `/v1/cars/search?model=X5` → tots els cotxes amb "X5" al model
- `/v1/cars/search?make=BMW&model=X` → BMW amb "X" al model

**Implementa** el mètode `getCarsByFilter` a la classe `CarHttpService` existent, seguint el mateix patrons que `getCarsPage`:

```dart
// Afegeix aquest mètode a car_http_service.dart:


```

Requisits:

1. Utilitza el mètode privat `_buildUri(String path, Map<String, String> queryParams)` ja existent.
2. Només afegeix els paràmetres `make` i/o `model` al mapa si el valor no és `null` ni buit (`isEmpty`).
3. Gestiona errors i timeout amb el mateix mecanisme que `getCarsPage`.

**Resposta:**

```dart
// Escriu aquí la teva implementació completa del mètode:
  Future<List<CarsModel>> getCarsByFilter({String? make, String? model}) async {
    final queryParams = <String, String>{};
    if (make != null && make.isNotEmpty) queryParams['make'] = make;
    if (model != null && model.isNotEmpty) queryParams['model'] = model;

    final uri = _buildUri('/v1/cars/search', queryParams);

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return CarsModel.listFromJsonString(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Han pasado mas de 10s');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
```

---

## Resum de l'examen

| Bloc | RA | Punts màxims |
|------|----|:------------:|
| Bloc 1 – Arquitectura i Cicle de vida | RA 2 | 25 |
| Bloc 2 – Comunicació, Persistència i Proves | RA 2  | 35 |
| Bloc 3 – `CarDetailPage` (base) | RA 3 | 20 |
| Bloc 3 – Ampliació `FutureBuilder`  | RA 3 | 10 |
| Bloc 4 – Extensió del servei HTTP | RA 2 | 10 |
| **TOTAL** | | **100** |

---
