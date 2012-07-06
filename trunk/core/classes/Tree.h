#pragma once

template<typename Type>
class Tree
{
public:
	class Node
	{
	public:
		Node(Node* Parent = 0)
			: m_parent(Parent)
			, m_child(0)
			, m_next(0)
			, m_prev(0)
		{
		}

		~Node();

		Type& data()
		{
			return m_data;
		}
		Type& data() const
		{
			return m_data;
		}
		Type* operator->()
		{
			return &m_data;
		}

		int level(){ return m_level; }
		Node* parent(){return m_parent;}
		Node* next()  {return m_next;}
		Node* prev()  {return m_prev;}
		Node* firstChild() {return m_child;}
		Node* lastChild();
		Node* firstSibling();
		Node* lastSibling();
		Node* addChild();
		Node* addBefore();
		Node* addAfter();
		Node* addSibling();
		int childCount()
		{
			return m_children;
		}
		void clear();

	protected:
		Type m_data;
		Node* m_parent;
		Node* m_child;
		Node* m_next;
		Node* m_prev;
		int m_level;
		int m_children;
	};

public:
	Node& root()
	{
		return m_root;
	}

protected:
	Node m_root;
};

template<typename Type>
Tree<Type>::Node::~Node()
{
	if (m_parent)
	{
		m_parent->m_children--;
		if(m_parent->m_child == this)
		{
			m_parent->m_child = this->m_next;
		}
	}
	if (m_prev)
	{
		m_prev->m_next = m_next;
	}
	if (m_next)
	{
		m_next->m_prev = m_prev;
	}

	Node* node = firstChild();
	Node* next = 0;
	while (node)
	{
		next = node->next();
		delete node;
		node = next;
	}
}


template <typename Type>
void Tree<Type>::Node::clear()
{
	Node* node = firstChild();
	while (node != NULL)
	{
		Node* next = node->next();
		delete node;
		node = next;
	}
}

template <typename Type>
typename Tree<Type>::Node* Tree<Type>::Node::lastChild()
{
	return (m_child == NULL) ? NULL : m_child->lastSibling();
}

template <typename Type>
typename Tree<Type>::Node* Tree<Type>::Node::firstSibling()
{
	Node* node = this;
	while (node->prev() != NULL)
	{
		node = node->prev();
	}
	return node;
}

template <typename Type>
typename Tree<Type>::Node* Tree<Type>::Node::lastSibling()
{
	Node* node = this;
	while (node->next() != NULL)
	{
		node = node->next();
	}
	return node;
}

template <typename Type>
typename Tree<Type>::Node* Tree<Type>::Node::addChild()
{
	Node* node = new Node(this);
	if (m_child == NULL)
	{
		m_child = node;
	}
	else
	{
		Node* last = lastChild();
		last->m_next = node;
		node->m_prev = last;
	}

	node->m_level = m_level + 1;
	node->m_next = 0;
	m_children++;
	return node;
}

template <typename Type>
typename Tree<Type>::Node* Tree<Type>::Node::addSibling()
{
	Node* node = new Node(m_parent);
	Node* last = lastSibling();
	last->m_next = node;
	node->m_prev = last;
	node->m_next = 0;
	node->m_level = m_level;
	
	if(m_parent != NULL)
	{
		m_parent->m_children++;
	}
	return node;
}

template <typename Type>
typename Tree<Type>::Node* Tree<Type>::Node::addBefore()
{
	Node *node = new Node(m_parent);
	if (m_prev != NULL)
	{
		m_prev->m_next = node;
	}
	if (m_parent != NULL && m_parent->m_child == this)
	{
		m_parent->m_child = node;
	}
	node->m_prev = m_prev;
	node->m_next = this;
	m_prev = node;
	node->m_level = m_level;
	if (m_parent != NULL)
	{
		m_parent->m_children++;
	}
	return node;
}

template <typename Type>
typename Tree<Type>::Node* Tree<Type>::Node::addAfter()
{
	Node *node = new Node(m_parent);
	if (m_next != NULL)
	{
		m_next->m_prev = node;
	}
	node->m_prev = this;
	node->m_next = m_next;
	m_next = node;
	node->m_level = m_level;
	if(m_parent)
	{
		m_parent->m_children++;
	}
	return node;
}
