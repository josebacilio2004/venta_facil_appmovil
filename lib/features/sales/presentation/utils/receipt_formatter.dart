import '../../domain/entities/receipt_data.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class ReceiptFormatter {
  static String formatToPlainText(ReceiptData receipt, {int width = 32}) {
    final buffer = StringBuffer();

    String center(String text) {
      if (text.length >= width) return text;
      final leftPadding = (width - text.length) ~/ 2;
      return '${' ' * leftPadding}$text';
    }

    String row(String left, String right) {
      final spaces = width - left.length - right.length;
      if (spaces <= 0) return '$left $right';
      return '$left${' ' * spaces}$right';
    }

    String divider([String char = '-']) => char * width;

    // Header
    buffer.writeln(center(receipt.issuerName.toUpperCase()));
    buffer.writeln(center('RUC: ${receipt.issuerRuc}'));
    buffer.writeln(center(receipt.issuerAddress));
    if (receipt.issuerPhone.isNotEmpty) {
      buffer.writeln(center('TELF: ${receipt.issuerPhone}'));
    }
    buffer.writeln(divider('='));
    
    // Document Title & Serial
    buffer.writeln(center(receipt.documentTitle));
    buffer.writeln(center('NRO: ${receipt.seriesNumber}'));
    if (receipt.documentType == DocumentType.ticket) {
      buffer.writeln(center('SERIE MÁQUINA: ${receipt.machineSeries}'));
    }
    buffer.writeln(divider('-'));

    // Date & Customer
    buffer.writeln(row('FECHA:', DateFormatter.formatDateTime(receipt.emissionDate)));
    buffer.writeln(row('CLIENTE:', receipt.customerName));
    if (receipt.customerDocNumber.isNotEmpty && receipt.customerDocNumber != '-') {
      buffer.writeln(row('${receipt.customerDocType}:', receipt.customerDocNumber));
    }
    if (receipt.customerAddress != null && receipt.customerAddress!.isNotEmpty) {
      buffer.writeln('DIR: ${receipt.customerAddress}');
    }
    buffer.writeln(divider('-'));

    // Items table
    buffer.writeln(row('CANT. DESCRIPCIÓN', 'TOTAL'));
    buffer.writeln(divider('-'));

    for (final item in receipt.items) {
      final descLine = '${item.quantity} ${item.unitMeasure} x ${item.productName}';
      final priceStr = CurrencyFormatter.format(item.subtotal);
      
      if (descLine.length + priceStr.length + 1 > width) {
        buffer.writeln(descLine);
        buffer.writeln(row('  @ ${CurrencyFormatter.format(item.unitPrice)}', priceStr));
      } else {
        buffer.writeln(row(descLine, priceStr));
      }
    }
    buffer.writeln(divider('-'));

    // Tax Breakdown & Totals
    if (receipt.discount > 0) {
      buffer.writeln(row('SUBTOTAL:', CurrencyFormatter.format(receipt.subtotal)));
      buffer.writeln(row('DESCUENTO:', '- ${CurrencyFormatter.format(receipt.discount)}'));
    }

    if (receipt.documentType == DocumentType.boleta) {
      buffer.writeln(row('OP. GRAVADA:', CurrencyFormatter.format(receipt.taxableAmount)));
      buffer.writeln(row('I.G.V. (18%):', CurrencyFormatter.format(receipt.igvAmount)));
    }

    buffer.writeln(divider('='));
    buffer.writeln(row('TOTAL A PAGAR:', CurrencyFormatter.format(receipt.total)));
    buffer.writeln(divider('='));

    // Footer & Payment Details
    buffer.writeln(row('FORMA DE PAGO:', receipt.paymentMethod.toUpperCase()));
    if (receipt.cashReceived != null && receipt.cashReceived! > 0) {
      buffer.writeln(row('EFECTIVO RECIBIDO:', CurrencyFormatter.format(receipt.cashReceived!)));
      if (receipt.changeGiven != null) {
        buffer.writeln(row('VUELTO / CAMBIO:', CurrencyFormatter.format(receipt.changeGiven!)));
      }
    }
    buffer.writeln(divider('-'));
    if (receipt.documentType == DocumentType.boleta) {
      buffer.writeln(center('Representación impresa de la'));
      buffer.writeln(center('BOLETA DE VENTA ELECTRÓNICA'));
      buffer.writeln(center('Autorizado mediante Resolucion SUNAT'));
    } else {
      buffer.writeln(center('COMPROBANTE AUTOGENERADO'));
      buffer.writeln(center('GRACIAS POR SU PREFERENCIA'));
    }
    buffer.writeln(divider('='));
    buffer.writeln(center('VENTAFACIL APP'));

    return buffer.toString();
  }
}
