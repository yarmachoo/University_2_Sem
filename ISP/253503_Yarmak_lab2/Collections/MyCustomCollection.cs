namespace DefaultNamespace;

public class MyCustomCollection<T> : ICustomCollection<T>
{
    private class Node
        {
            private T data;
            private Node next;

            public Node(T data)
            {
                this.data = data;
            }

            public T Data
            {
                get { return data; }
                set { data = value; }
            }

            public Node Next { 
                get { return next; }
                set { next = value; }
            }

        }

        private Node pointer;
        private Node begin;
        private Node end;

        int count;

        public MyCustomCollection()
        {
            this.pointer = null;
            this.begin = null;
            this.end = null;
            this.count = 0;
        }

        public int Count
        {  get { return count; } }

        public T this[int index]
        {
            get
            {
                if(index<0 || index > count-1 ) { throw new IndexOutOfRangeException(); }

                Node foundedPointer = begin;
                while (index-- > 0)
                {
                    foundedPointer = foundedPointer.Next;
                }

                return foundedPointer.Data;
            }
            set
            {
                if (index < 0 || index > count - 1) { throw new IndexOutOfRangeException(); }

                Node foundedPointer = begin;

                while (index-- > 0)
                {
                    foundedPointer = foundedPointer.Next;
                }

                foundedPointer.Data = value;
            }
        }

        public void Add(T item)
        {
            count++;

            // проверка на пустоту
            if (end == null)
            {
                end = new Node(item);
                begin = end;
                pointer = begin;
                return;
            }

            end.Next = new Node(item);
            end = end.Next;
        }

        public T Current()
        {
            if (pointer == null)
            {
                throw new IndexOutOfRangeException();
            }

            return pointer.Data;
        }

        public void Next()
        {
            if (pointer == null)
            {
                throw new IndexOutOfRangeException();
            }

            pointer = pointer.Next;
        }

        private void RemoveByPointer(Node pointerToRemove)
        {
            //проверка на удаление начального элемента
            if (pointerToRemove == begin)
            {
                begin = begin.Next;

                if (pointer == pointerToRemove)
                {
                    pointer = begin;
                }

                --count;
                return;
            }
            Node foundedPointer = begin;

            // ищем указатель для удаления
            while (foundedPointer.Next != null)
            {
                if (pointerToRemove.Equals(foundedPointer.Next))
                {
                    foundedPointer.Next = pointerToRemove.Next;
                    count--;

                    // setting pointer to previous position when pointer to remove equals pointer
                    // назначение указателя на предыдущую позицию когда удаляемый указатель равен нашему
                    if (pointer == pointerToRemove)
                    {
                        pointer = foundedPointer;
                    }

                    // setting end to previous position when pointer to remove equals pointer
                    // назначение end указателя на предыдущую позицию когда удаляемый указатель равен нашему
                    if (end == pointerToRemove)
                    {
                        end = foundedPointer;
                    }
                    return;
                }

                foundedPointer = foundedPointer.Next;
            }
        }

        public T RemoveCurrent()
        {
            if (pointer == null)
            {
                throw new IndexOutOfRangeException();
            }

            T data = pointer.Data;
            RemoveByPointer(pointer);
            return data;
        }

        public void Reset()
        {
            pointer = begin;
        }

        public void Remove(T item)
        {
            if (begin == null)
            {
                return;
            }

            Node foundedPointer = begin;

            // поиск указателя для удаления
            while (foundedPointer != null)
            {
                if (foundedPointer.Data.Equals(item))
                {
                    RemoveByPointer(foundedPointer);
                    return;
                }
                foundedPointer = foundedPointer.Next;
            }
        }

        public int Length()
        {  return count; }
}