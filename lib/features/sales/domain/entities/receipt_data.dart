enum DocumentType {
  ticket,
  boleta,
}

class ReceiptItemData {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String unitMeasure;

  const ReceiptItemData({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.unitMeasure = 'UND',
  });
}

class ReceiptData {
  final int saleId;
  final DocumentType documentType;
  final String seriesNumber;
  final String machineSeries;
  final DateTime emissionDate;
  
  // Datos del Emisor (Empresa)
  final String issuerName;
  final String issuerRuc;
  final String issuerAddress;
  final String issuerPhone;

  // Datos del Adquiriente / Cliente
  final String customerName;
  final String customerDocType;
  final String customerDocNumber;
  final String? customerAddress;

  // Detalle de Ítems
  final List<ReceiptItemData> items;
  
  // Desglose Tributario SUNAT
  final double subtotal;
  final double discount;
  final double taxableAmount;
  final double igvAmount;
  final double total;
  final String paymentMethod;
  final String currency;

  const ReceiptData({
    required this.saleId,
    required this.documentType,
    required this.seriesNumber,
    required this.machineSeries,
    required this.emissionDate,
    required this.issuerName,
    required this.issuerRuc,
    required this.issuerAddress,
    required this.issuerPhone,
    required this.customerName,
    required this.customerDocType,
    required this.customerDocNumber,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.taxableAmount,
    required this.igvAmount,
    required this.total,
    required this.paymentMethod,
    this.currency = 'S/.',
  });

  String get documentTitle {
    switch (documentType) {
      case DocumentType.ticket:
        return 'TICKET DE MÁQUINA REGISTRADORA';
      case DocumentType.boleta:
        return 'BOLETA DE VENTA ELECTRÓNICA';
    }
  }

  String get sunatQrPayload {
    final tipoComp = documentType == DocumentType.boleta ? '03' : '12';
    final parts = seriesNumber.split('-');
    final serie = parts.isNotEmpty ? parts[0] : 'B001';
    final correlativo = parts.length > 1 ? parts[1] : '$saleId';
    final fecha = "${emissionDate.year}-${emissionDate.month.toString().padLeft(2, '0')}-${emissionDate.day.toString().padLeft(2, '0')}";
    final tipoDocCli = customerDocType == 'DNI' ? '1' : (customerDocType == 'RUC' ? '6' : '-');
    return "$issuerRuc|$tipoComp|$serie|$correlativo|${igvAmount.toStringAsFixed(2)}|${total.toStringAsFixed(2)}|$fecha|$tipoDocCli|$customerDocNumber";
  }
}
