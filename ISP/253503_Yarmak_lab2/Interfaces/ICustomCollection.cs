namespace DefaultNamespace;

public interface ICustomCollection<T>
{
    T this[int index] { get; set; }
    void Reset();
    void Next();
    T Current();
    int Count { get; }
    void Add(T item);
    T RemoveCurrent();
    void Remove(T item);
}