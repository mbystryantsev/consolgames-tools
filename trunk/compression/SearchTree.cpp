#include "SearchTree.h"
#include <algorithm>

namespace Consolgames
{

namespace Compression
{

SearchTree::Node::Node()
	: charIndex(-1)
	, height(0)
	, left(NULL)
	, right(NULL)
{
}

bool SearchTree::Node::isNull() const
{
	return (height == 0);
}

int SearchTree::Node::nodeHeight(Node* node)
{
	return (node == NULL ? 0 : node->height);
}

int SearchTree::Node::balanceFactor() const
{
	return nodeHeight(right) - nodeHeight(left);
}

void SearchTree::Node::fixHeight()
{
	const int leftHeight = nodeHeight(left);
	const int rightHeight = nodeHeight(right);

	height = (rightHeight > leftHeight ? rightHeight : leftHeight) + 1;
}

SearchTree::Node* SearchTree::Node::rotateRight()
{
	// rotate around p
	Node* p = this;
	Node* q = p->left;

	p->left = q->right;
	q->right = p;
	p->fixHeight();
	q->fixHeight();
	return q;
}

SearchTree::Node* SearchTree::Node::rotateLeft()
{
	// rotate around q
	Node* q = this;
	Node* p = q->right;
	
	q->right = p->left;
	p->left = q;
	q->fixHeight();
	p->fixHeight();
	return p;
}

SearchTree::Node* SearchTree::Node::performBalance()
{
	fixHeight();

	ASSERT(balanceFactor() >= -2 && balanceFactor() <= 2);

	if (balanceFactor() == 2)
	{
		if (right->balanceFactor() < 0)
		{
			right = right->rotateRight();
		}
		return rotateLeft();
	}
	else if(balanceFactor() == -2)
	{
		if (left->balanceFactor() > 0)
		{
			left = left->rotateLeft();
		}
		return rotateRight();
	}

	return this;
}

void SearchTree::Node::reset()
{
	left = NULL;
	right = NULL;
	height = 0;
}

//////////////////////////////////////////////////////////////////////////

SearchTree::SearchTree(const uint8* window, int windowSize, int maxStringLength)
	: m_window(window)
	, m_windowSize(windowSize)
	, m_maxStringLength(maxStringLength)
	, m_root(NULL)
{
	ASSERT(maxStringLength > 0);
	ASSERT(windowSize >= maxStringLength);

	m_nodes.resize(windowSize);
	for (int i = 0; i < windowSize; i++)
	{
		m_nodes[i].charIndex = i;
	}
}

void SearchTree::insert(int charIndex)
{
	ASSERT(charIndex >= 0 && charIndex < m_windowSize);
	
	Node* node = &m_nodes[charIndex];
	ASSERT(node->isNull());

	if (!node->isNull())
	{
		remove(charIndex);
	}

	m_root = insertString(m_root, charIndex);
}

void SearchTree::remove(int charIndex)
{
	if (m_nodes[charIndex].isNull())
	{
		return;
	}

	m_root = removeString(m_root, charIndex);
}

void SearchTree::clear()
{
	for (std::vector<Node>::iterator node = m_nodes.begin(); node != m_nodes.end(); node++)
	{
		node->reset();
	}
	m_root = NULL;
}

void SearchTree::build()
{
	clear();
	for (int i = 0; i < m_windowSize; i++)
	{
		insert(i);
	}
}

bool SearchTree::hasString(int charIndex) const
{
	ASSERT(charIndex >= 0 && charIndex < static_cast<int>(m_nodes.size()));
	return !m_nodes[charIndex].isNull();
}

SearchTree::Node* SearchTree::insertString(Node* node, int charIndex)
{
	if (node == NULL)
	{
		Node* newNode = &m_nodes[charIndex];
		ASSERT(newNode->isNull());
		newNode->height = 1;
		return newNode;
	}

	ASSERT(!node->isNull());

	const int comparisonResult = compare(charIndex, node->charIndex);

	if (comparisonResult < 0)
	{
		node->left = insertString(node->left, charIndex);
	}
	else if (comparisonResult > 0)
	{
		node->right = insertString(node->right, charIndex);
	}
	else
	{
		// just replace
		Node* newNode = &m_nodes[charIndex];
		newNode->left = node->left;
		newNode->right = node->right;
		newNode->height = node->height;
		node->reset();

		return newNode;
	}

	return node->performBalance();
}

int SearchTree::compare(int firstIndex, int secondIndex) const
{
	ASSERT(firstIndex != secondIndex);

	if (firstIndex == secondIndex)
	{
		return 0;
	}

	const uint8* c1 = m_window + firstIndex;
	const uint8* c2 = m_window + secondIndex;
	const uint8* const end = m_window + m_windowSize;

	int result = 0;

	for (int offset = 0; offset < m_maxStringLength; offset++)
	{
		result = *c1++ - *c2++;
		if (result != 0)
		{
			break;
		}

		if (c1 == end)
		{
			c1 = m_window;
		}
		else if (c2 == end)
		{
			c2 = m_window;
		}
	}

	return result;
}

SearchTree::SearchResult SearchTree::find(int charIndex, int maxLength) const
{
	return findString(m_window, m_windowSize, charIndex, maxLength);
}

SearchTree::SearchResult SearchTree::find(const uint8* data, int length) const
{
	length = min(m_maxStringLength, length);
	return findString(data, length, 0, length);
}

SearchTree::SearchResult SearchTree::findString(const uint8* buffer, int bufferSize, int stringPosition, int stringLength) const
{
	SearchResult result;
	result.position = 0;
	result.length = 0;

	Node* node = m_root;

	const uint8* const end1 = buffer + bufferSize;
	const uint8* const end2 = m_window + m_windowSize;

	while (node != NULL)
	{
		ASSERT(!node->isNull());

		int comparisonResult = 0;
		int offset = 0;

		const uint8* c1 = buffer + (stringPosition % bufferSize);
		const uint8* c2 = m_window + node->charIndex;

		if (c1 == c2)
		{
			result.position = node->charIndex;
			result.length = stringLength;
			break;
		}

		while (offset < stringLength)	
		{
			comparisonResult = *c1++ - *c2++;
			if (comparisonResult != 0)
			{
				break;
			}

			if (c1 == end1)
			{
				c1 = buffer;
			}
			else if (c2 == end2)
			{
				c2 = m_window;
			}

			offset++;
		}

		if (offset > result.length)
		{
			result.position = node->charIndex;
			result.length = offset;
		}

		if (result.length == stringLength)
		{
			break;
		}

		node = (comparisonResult < 0 ? node->left : node->right);
	}

	return result;
}

SearchTree::Node* SearchTree::findMinimumString(Node* node)
{
	while (node->left != NULL)
	{
		node = node->left;
	}
	return node;
}

SearchTree::Node* SearchTree::removeMinimumString(Node* node)
{
	if (node->left == NULL)
	{
		return node->right;
	}

	node->left = removeMinimumString(node->left);
	return node->performBalance();
}

SearchTree::Node* SearchTree::removeString(Node* node, int charIndex)
{
	if (node == NULL)
	{
		ASSERT(!"Node not found!");
		return NULL;
	}

	ASSERT(!node->isNull());

	if (node->charIndex == charIndex)
	{
		Node* q = node->left;
		Node* r = node->right;
		node->reset();

		if (r == NULL)
		{
			return q;
		}

		Node* minimum = findMinimumString(r);
		minimum->right = removeMinimumString(r);
		minimum->left = q;
		return minimum->performBalance();
	}

	const int comparisonResult = compare(charIndex, node->charIndex);
	if (comparisonResult < 0)
	{
		node->left = removeString(node->left, charIndex);
	}
	else
	{
		node->right = removeString(node->right, charIndex);
	}

	return node->performBalance();
}

}

}