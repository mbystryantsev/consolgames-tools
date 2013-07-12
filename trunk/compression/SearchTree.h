#pragma once
#include <core.h>
#include <vector>

namespace Consolgames
{

namespace Compression
{

class SearchTree
{
private:
	struct Node
	{
		Node();
		bool isNull() const;
		static int nodeHeight(Node* node);
		int balanceFactor() const;
		void fixHeight();
		void reset();
		Node* rotateRight();
		Node* rotateLeft();
		Node* performBalance();

		int charIndex;
		int height;
		Node* left;
		Node* right;
	};

public:
	struct SearchResult
	{
		SearchResult()
			: position(0)
			, length(0)
		{
		}

		int position;
		int length;
	};

public:
	SearchTree(const uint8* window, int windowSize, int maxStringLength);

	void insert(int charIndex);
	void remove(int charIndex);
	void clear();
	void build();
	bool hasString(int charIndex) const;

	SearchResult find(int charIndex, int maxLength) const;
	SearchResult find(const uint8* data, int length) const;

private:
	static int nodeHeight(Node* node);
	static int balanceFactor(Node* node);
	Node* insertString(Node* node, int charIndex);
	Node* removeString(Node* node, int charIndex);
	int compare(int fistIndex, int secondIndex) const;
	SearchResult findString(const uint8* buffer, int bufferSize, int stringPosition, int stringLength) const;
	Node* findMinimumString(Node* node);
	Node* removeMinimumString(Node* node);

private:
	const uint8* m_window;
	const int m_windowSize;
	const int m_maxStringLength;
	std::vector<Node> m_nodes;
	Node* m_root;
};

}

}