import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:intl/intl.dart';

/// French message for a failed API call.
String errorMessage(String code) => switch (code) {
  CoopApiException.network => 'Connexion impossible. Vérifiez votre accès à Internet.',
  CoopApiException.notACoopServer => "Cette adresse n'est pas celle d'une coopérative compatible.",
  'INVALID_CREDENTIALS' => 'Identifiant ou mot de passe incorrect.',
  'MFA_NOT_SUPPORTED' => 'Les comptes protégés par une double authentification ne sont pas encore pris en charge.',
  _ => 'Une erreur est survenue ($code). Réessayez plus tard.',
};

final _quantityFormat = NumberFormat('#.##', 'fr');
final _priceFormat = NumberFormat.currency(locale: 'fr', symbol: '€');
final _dayFormat = DateFormat('d MMM', 'fr');

/// Odoo's default unit, which adds nothing next to a count.
const _plainUnits = kPieceUnits;

/// "2", "0,75 kg".
String quantityLabel(double quantity, String uom) =>
    _plainUnits.contains(uom) ? _quantityFormat.format(quantity) : '${_quantityFormat.format(quantity)} $uom';

/// "9,80 €"
String priceLabel(double amount) => _priceFormat.format(amount);

/// "4,90 €" — per unit of measure when the product is not sold by the piece.
String unitPriceLabel(double price, String uom) =>
    _plainUnits.contains(uom) ? _priceFormat.format(price) : '${_priceFormat.format(price)} / $uom';

/// "+0,40 €", "−0,30 €".
String priceDeltaLabel(double delta) => '${delta < 0 ? '−' : '+'}${_priceFormat.format(delta.abs())}';

/// "2 nov."
String dayLabel(DateTime day) => _dayFormat.format(day);
