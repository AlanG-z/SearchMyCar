import 'package:flutter/material.dart';

class InicioPage extends StatelessWidget {
	const InicioPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('SearchMyCar'),
				backgroundColor: Colors.orange,
				foregroundColor: Colors.white,
			),
			body: Center(
				child: Padding(
					padding: const EdgeInsets.all(24),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(
								Icons.directions_car,
								size: 96,
								color: Colors.orange.shade700,
							),
							const SizedBox(height: 24),
							const Text(
								'¡Bienvenido a SearchMyCar!',
								textAlign: TextAlign.center,
								style: TextStyle(
									fontSize: 28,
									fontWeight: FontWeight.bold,
								),
							),
							const SizedBox(height: 12),
							const Text(
								'Encuentra y guarda la ubicación de tu vehículo fácilmente.',
								textAlign: TextAlign.center,
								style: TextStyle(fontSize: 16),
							),
							const SizedBox(height: 32),
							ElevatedButton.icon(
								onPressed: () {
									Navigator.pushReplacementNamed(context, '/home');
								},
								icon: const Icon(Icons.arrow_forward),
								label: const Text('Comenzar'),
							),
						],
					),
				),
			),
		);
	}
}
