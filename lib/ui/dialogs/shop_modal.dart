import 'package:flutter/material.dart';
import '../../models/profile.dart';

/// Modal inferior (BottomSheet) que despliega la tienda de diamantes y la suscripción PRO
class ShopModal extends StatelessWidget {
  final Profile profile;
  // Callback para procesar el pago ficticio en la pantalla principal
  final Function(String label, VoidCallback onOk) onPay;

  const ShopModal({
    super.key,
    required this.profile,
    required this.onPay,
  });

  // Constructor auxiliar de filas para los paquetes de diamantes disponibles
  Widget _buildPack(BuildContext context, int amount, String price) {
    return ListTile(
      leading: const Text('💎', style: TextStyle(fontSize: 28)),
      title: Text('$amount diamantes'),
      trailing: FilledButton(
        onPressed: () {
          Navigator.pop(context);
          onPay('$amount 💎', () => profile.addDiamonds(amount));  // Inicia el flujo de pago
        },
        child: Text(price),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea evita superposiciones con la barra de navegación del celular
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '🛒 Tienda',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          // Paquetes de consumibles
          _buildPack(context, 10, '\$0.99'),
          _buildPack(context, 50, '\$3.99'),
          _buildPack(context, 120, '\$7.99'),
          const Divider(),
          // Opción de compra única (Cuenta PRO)
          ListTile(
            leading: const Text('👑', style: TextStyle(fontSize: 28)),
            title: const Text('Cuenta PRO (sin anuncios)'),
            trailing: profile.pro
                ? const Text('¡Activa!')
                : FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onPay('Cuenta PRO', profile.setPro);  // Aplica el beneficio PRO al pagar
              },
              child: const Text('\$4.99'),
            ),
          ),
        ],
      ),
    );
  }
}