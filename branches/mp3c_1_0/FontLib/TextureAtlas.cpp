#include "TextureAtlas.h"

namespace Consolgames
{

TextureAtlas::Node::Node(int width, int height, int layer) : isUsed(false), layer(layer)
{
	rect.x1 = 0;
	rect.x2 = width;
	rect.y1 = 0;
	rect.y2 = height;
}

TextureAtlas::Node::Node(int x1, int x2, int y1, int y2, int layer) : isUsed(false), layer(layer)
{
	rect.x1 = x1;
	rect.x2 = x2;
	rect.y1 = y1;
	rect.y2 = y2;
}

const TextureAtlas::Node* TextureAtlas::Node::insert(int width, int height)
{
	const Node* result = NULL;
	if (firstChild.get() != NULL)
	{
		result = firstChild->insert(width, height);
		if (result == NULL)
		{
			result = secondChild->insert(width, height);
		}
		return result;
	}

	if (isUsed || width > rect.width() || height > rect.height())
	{
		return NULL;
	}

	if (width == rect.width() && height == rect.height())
	{
		isUsed = true;
		return this;
	}

	const int divWidth = rect.width() - width;
	const int divHeight = rect.height() - height;

	if (divWidth > divHeight)
	{
		firstChild.reset(new Node(rect.x1, rect.x1 + width, rect.y1, rect.y2, layer));
		secondChild.reset(new Node(rect.x1 + width, rect.x2, rect.y1, rect.y2, layer));
	}
	else
	{
		firstChild.reset(new Node(rect.x1, rect.x2, rect.y1, rect.y1 + height, layer));
		secondChild.reset(new Node(rect.x1, rect.x2, rect.y1 + height, rect.y2, layer));
	}
	return firstChild->insert(width, height);
}

TextureAtlas::TextureAtlas(int width, int height, int layerCount, bool interpolationHint)
{
	m_rootNodes.resize(layerCount);
	for (int i = 0; i < layerCount; i++)
	{
		m_rootNodes[i].reset(new Node(width, height, i));
		if (interpolationHint)
		{
			m_rootNodes[i]->insert(width, 1);
			m_rootNodes[i]->insert(1, height - 1);
		}
	}
}

const TextureAtlas::Node* TextureAtlas::insert(int width, int height)
{
	const Node* result = NULL;
	for (int i = 0; i < m_rootNodes.size(); i++)
	{
		result = m_rootNodes[i]->insert(width, height);
		if (result != NULL)
		{
			break;
		}
	}
	return result;
}

}
