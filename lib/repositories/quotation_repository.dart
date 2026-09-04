import '../models/quotation.dart';

abstract class QuotationRepository {
  Future<List<Quotation>> listQuotations();
  Future<Quotation> createQuotation(Quotation quotation);
  Future<Quotation> updateQuotation(Quotation quotation);
  Future<void> deleteQuotation(String id);
  Future<Quotation> updateStatus(String id, String newStatus);
}
