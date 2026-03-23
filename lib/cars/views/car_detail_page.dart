import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../services/car_http_service.dart';

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
