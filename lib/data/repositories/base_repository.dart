abstract class BaseRepository<T> {
  Future<List<T>> fetchAll();
  Future<T> add(T item);
  Future<T> update(T item);
  Future<void> delete(String id);
}
