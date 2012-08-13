#pragma once
#include <QVector>
#include <memory>

namespace Consolgames
{

class TextureAtlas
{
public:
	struct Rect
	{
		int width() const
		{
			return x2 - x1;
		}
		int height() const
		{
			return y2 - y1;
		}


		int x1;
		int x2;
		int y1;
		int y2;
	};
	struct Node
	{
		Node(int width, int height, int layer);
		Node(int x1, int x2, int y1, int y2, int layer);
		const Node* insert(int width, int height);
		int width() const;
		int height() const;

		Rect rect;
		bool isUsed;
		int layer;
		std::auto_ptr<Node> firstChild;
		std::auto_ptr<Node> secondChild;
	};

public:
	TextureAtlas(int width, int height, int layerCount = 1);
	const Node* insert(int width, int height);

protected:
	QVector<std::auto_ptr<Node>> m_rootNodes;
};

}
