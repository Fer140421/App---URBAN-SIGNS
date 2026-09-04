import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quotation.dart';
import 'quotation_repository.dart';

class SupabaseQuotationRepository implements QuotationRepository {
  SupabaseQuotationRepository(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Se requiere una sesión autenticada.');
    return id;
  }

  @override
  Future<List<Quotation>> listQuotations() async {
    final data = await _client
        .from('quotations')
        .select()
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((row) => Quotation.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<Quotation> createQuotation(Quotation quotation) async {
    final data = await _client
        .from('quotations')
        .insert(quotation.toDatabaseMap(owner: _userId))
        .select()
        .single();
    return Quotation.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<Quotation> updateQuotation(Quotation quotation) async {
    final payload = quotation.toDatabaseMap(owner: quotation.ownerId)..remove('owner_id');
    final data = await _client
        .from('quotations')
        .update(payload)
        .eq('id', quotation.id)
        .select()
        .single();
    return Quotation.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> deleteQuotation(String id) async {
    await _client.from('quotations').delete().eq('id', id);
  }

  @override
  Future<Quotation> updateStatus(String id, String newStatus) async {
    final data = await _client
        .from('quotations')
        .update({'status': newStatus})
        .eq('id', id)
        .select()
        .single();
    return Quotation.fromMap(Map<String, dynamic>.from(data));
  }
}
