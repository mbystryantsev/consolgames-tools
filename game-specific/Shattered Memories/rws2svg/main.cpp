#include <cstdio>
#include <Map.h>
#include <vector>
#include <windows.h>


struct Line
{
    float x, y;
};

typedef std::vector<SPolygon> PolygonArray;
typedef std::vector<SLine> LineArray;
typedef std::vector<PolygonArray*> PolygonArrayGroup;
typedef std::vector<SVertex> VertexArray;
typedef std::vector<VertexArray*> VertexArrayGroup;


bool pnpoly(CMap &map, std::vector<short>& points, short p)
{
    bool c = false;
    float x = map.vertexes[p].x,
              y = map.vertexes[p].y;

    for (int i = 0, j = points.size() - 1; i < (signed)points.size(); j = i++)
    {
        float xpi = map.vertexes[points[i]].x,
                    ypi = map.vertexes[points[i]].y,
                          xpj = map.vertexes[points[j]].x,
                                ypj = map.vertexes[points[j]].y;
        if ((((ypi<=y) && (y<ypj)) || ((ypj<=y) && (y<ypi))) &&
                (x > (xpj - xpi) * (y - ypi) / (ypj - ypi) + xpi))
            c = !c;
    }
    return c;
}

bool intersect(const SVertex& va1, const SVertex& va2, const SVertex& vb1, const SVertex& vb2)
{
    static float v1, v2, v3, v4;

    v1 = (vb2.x - vb1.x) * (va1.y - vb1.y) - (vb2.y - vb1.y) * (va1.x - vb1.x);
    v2 = (vb2.x - vb1.x) * (va2.y - vb1.y) - (vb2.y - vb1.y) * (va2.x - vb1.x);
    v3 = (va2.x - va1.x) * (vb1.y - va1.y) - (va2.y - va1.y) * (vb1.x - va1.x);
    v4 = (va2.x - va1.x) * (vb2.y - va1.y) - (va2.y - va1.y) * (vb2.x - va1.x);

/*
    v1 =(bx2-bx1)*(ay1-by1)-(by2-by1)*(ax1-bx1);
    v2 =(bx2-bx1)*(ay2-by1)-(by2-by1)*(ax2-bx1);
    v3 =(ax2-ax1)*(by1-ay1)-(ay2-ay1)*(bx1-ax1);
    v4 =(ax2-ax1)*(by2-ay1)-(ay2-ay1)*(bx2-ax1);
*/
    return (v1*v2<0) && (v3*v4<0);
}

bool intersect(CMap &map, short a1, short a2, short b1, short b2)
{
    static SVertex va1, va2, vb1, vb2;
    va1 = map.vertexes[a1];
    va2 = map.vertexes[a2];
    vb1 = map.vertexes[b1];
    vb2 = map.vertexes[b2];
    return intersect(va1, va2, vb1, vb2);
}

int commonPoints(SPolygon &p1, SPolygon &p2, int &index1, int &index2)
{
    int exc_1 = -1, exc_2 = -1, common = 0;
    for(int i = 0; i < 3; i++)
    {
        if(i == exc_1) continue;
        for(int j = 0; j < 3; j++)
        {
            if(j == exc_2) continue;
            if(p1.v[i] == p2.v[j])
            {
                common++;
                if(exc_1 >= 0)
                {
                    if((index1 == 0 && i == 1) || (i == 0 && index1 == 1)) index1 = 2;
                    else if((index1 == 1 && i == 2) || (i == 1 && index1 == 2)) index1 = 0;
                    else if((index1 == 2 && i == 0) || (i == 2 && index1 == 0)) index1 = 1;

                    if((index2 == 0 && j == 1) || (j == 0 && index2 == 1)) index2 = 2;
                    else if((index2 == 1 && j == 2) || (j == 1 && index2 == 2)) index2 = 0;
                    else if((index2 == 2 && j == 0) || (j == 2 && index2 == 0)) index2 = 1;

                    if(p1.v[index1] == p2.v[index2]) common++;

                    return common;

                }
                else
                {
                    index1 = i;
                    index2 = j;
                    exc_1 = i;
                    exc_2 = j;
                }
                break;
            }
        }
    }
    return common;
}

int commonPoints(SPolygon &p1, SPolygon &p2)
{
    int index1, index2;
    return commonPoints(p1, p2, index1, index2);
}

bool LineIntersect(CMap& map, short v1, short v2, std::vector<short>& points)
{
    for(unsigned int i = 0; i < points.size(); i++)
    {
        if(intersect(map, v1, v2, points[i], points[(i + 1) % points.size()])) return true;
    }
    return false;
}

bool PointIn(short p, const std::vector<short>& v)
{
    for(unsigned int i = 0; i < v.size(); i++)
    {
        if(v[i] == p)
            return true;
    }
    return false;
}

bool fetchPolygon(std::vector<short>& points, PolygonArray& polygons, int color, CMap& map)
{
    int point = -1, polygon = -1;
    bool matches[3] = {false, false, false}, finded = false;
    short vertex = -1;
    int vertex_id = -1;
    for(unsigned int i = 0; i < polygons.size(); i++)
    {
        if(polygons[i].color != color) continue;
        for(int v = 0; v < 3; v++)
        {
            short v1 = polygons[i].v[(v + 0) % 3];
            short v2 = polygons[i].v[(v + 1) % 3];
            short v3 = polygons[i].v[(v + 2) % 3];
            for(unsigned int j = 0; j < points.size(); j++)
            {
                if((v1 == points[j] && v2 == points[(j+1) % points.size()]) || (v1 == points[(j+1) % points.size()] && v2 == points[j]))
                {
                    //if(v3 == points[(j+2) % points.size()])
                    //if(PointIn(v3, points))
                    //{
                    //    finded = false;
                    //    continue;
                   // }
                    matches[(v + 0) % 3] = true;
                    matches[(v + 1) % 3] = true;
                    for(int k = 0; k < 3; k++)
                    {
                        if(!matches[k])
                        {
                            vertex = polygons[i].v[k];
                            vertex_id = k;
                            break;
                        }
                    }
                    finded = true;
                    for(unsigned int k = 0; k < points.size(); k++)
                    {
                        if(points[k] == vertex)
                        {
                            finded = false;
                            break;
                        }
                    }

                    if(finded)
                    {
                        if(
                           pnpoly(map, points, vertex)
                           || LineIntersect(map, polygons[i].v[(vertex_id + 1) % 3], vertex, points)
                           || LineIntersect(map, polygons[i].v[(vertex_id + 2) % 3], vertex, points)
                        )
                        {
                            finded = false;
                        }
                    }


                    if(finded)
                    {
                        point = j + 1;
                        polygon = i;
                        break;
                    }
                    else
                    {
                        for(int k = 0; k < 3; k++)
                            matches[k] = false;
                    }
                }
            }
        }
        if(finded)
            break;
    }

    if(finded)
    {
        points.insert(points.begin() + point, vertex);
        polygons.erase(polygons.begin() + polygon);
        return true;
    }

    return false;
}



int writeColor(char* str, SColor c)
{
    return sprintf(str, "#%2.2X%2.2X%2.2X", c.r, c.g, c.b);
}

void writePoints(char* &s, std::vector<short>& points, CMap& map)
{
    for(unsigned int i = 0; i < points.size(); i++)
    {
        SVertex v = map.vertexes[points[i]];
        if(i > 0)
            s += sprintf(s, " ");
        s += sprintf(s, "%.1f,%.1f", v.x, v.y);
    }
}

void groupPolygons(SPolygon *polygons, int count, CMap &map, char* &s)
{
    std::vector<SPolygon> src;
    std::vector<SLine> lines;

    for(int i = 0; i < count; i++)
    {
        src.push_back(polygons[i]);
    }

    // remove duplicates
    for(unsigned int i = 0; i < src.size(); i++)
    {
        for(unsigned int j = i + 1; j < src.size(); j++)
        {
            if(src[i].color == src[j].color && commonPoints(src[i], src[j]) == 3)
            {
                src.erase(src.begin() + j);
                j--;
            }
        }
    }

    std::vector<short> points;

    while(src.size() > 0)
    {
        points.clear();
        points.push_back(src[0].v[0]);
        points.push_back(src[0].v[1]);
        points.push_back(src[0].v[2]);

        int c = src[0].color;
        src.erase(src.begin() + 0);
        while(
            //fetchPolygon(dest, src)
            fetchPolygon(points, src, c, map)
        );

        s += sprintf(s, "<polygon points=\"");
        writePoints(s, points, map);
        static char color[10];
        writeColor(color, map.colors[c]);
        s += sprintf(s, "\" fill=\"%s\"/>", color);
    }
}

bool fetchLine(std::vector<short>& points, std::vector<SLine>& lines, int color)
{
    short vertex = points[points.size() - 1];
    bool finded = false, to_begin = false;
    for(unsigned int i = 0; i < lines.size(); i++)
    {
        if(lines[i].color == color)
        {
            finded = true;
            if(lines[i].v[0] == vertex)
                vertex = lines[i].v[1];
            else if (lines[i].v[1] == vertex)
                vertex = lines[i].v[0];
            else if(lines[i].v[0] == points[0])
            {
                to_begin = true;
                vertex = lines[i].v[1];
            }
            else if (lines[i].v[1] == points[0])
            {
                to_begin = true;
                vertex = lines[i].v[0];
            }
            else
                finded = false;
        }
        if(finded)
        {
            if(to_begin)
                points.insert(points.begin() + 0, vertex);
            else
                points.push_back(vertex);
            lines.erase(lines.begin() + i);
            return true;
        }
    }
    return false;
}

void groupLines(SLine *lines, int count, CMap &map, char* &s)
{
    std::vector<SLine> src;

    for(int i = 0; i < count; i++)
        src.push_back(lines[i]);

    std::vector<short> points;
    while( src.size() > 0 )
    {
        points.clear();
        points.push_back(src[0].v[0]);
        points.push_back(src[0].v[1]);

        int c = src[0].color;
        src.erase(src.begin() + 0);

        while (
            fetchLine(points, src, c)
        );

        static char color[10];
        writeColor(color, map.colors[c]);

        if(points.size() == 2)
        {
            SVertex v1 = map.vertexes[points[0]], v2 = map.vertexes[points[1]];
            s += sprintf(s, "<line x1=\"%.1f\" y1=\"%.1f\" x2=\"%.1f\" y2=\"%.1f", v1.x, v1.y, v2.x, v2.y);
        }
        else
        {
            SVertex v = map.vertexes[points[0]];
            s += sprintf(s, "<path fill=\"none\" d=\"M%.1f %.1f", v.x, v.y);
            for(unsigned int i = 1; i < points.size(); i++)
            {
                v = map.vertexes[points[i]];
                s += sprintf(s, " L%.1f %.1f", v.x, v.y);
            }
            //s += sprintf(s, " Z");
        }
        s += sprintf(s, "\" stroke-width=\"1\" stroke=\"%s\"/>", color);
    }
}


/*
int writeLine(char* str, int x, int y, int x2, int y2, SColor c)
{
    static char color[8];
    writeColor(color, c);
    return sprintf(str, "<line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke=\"%s\"/>", x, y, x2, y2, color);
}

int writePolygon(char* str, SVertex v1, SVertex v2, SVertex v3, SColor c)
{
    static char color[8];
    writeColor(color, c);
    return sprintf(str, "<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f\" fill=\"%s\" />", v1.x, v1.y, v2.x, v2.y, v3.x, v3.y, color);
}

int writePolyChain(char* &s, SPolygon *p, int count, CMap *map)
{
    int i = 1;
    SVertex v1, v2, v3;
    v1 = map->vertexes[p->v[0]];
    v2 = map->vertexes[p->v[1]];
    v3 = map->vertexes[p->v[2]];
    s += sprintf(s, "<polygon points=\"%.1f,%.1f %.1f,%.1f %.1f,%.1f", v1.x, v1.y, v2.x, v2.y, v3.x, v3.y);
    for(; i < count; i++)
    {
        if(p[i].color != p[i-1].color)
        {
            break;
        }
        else if(false && p[i].v[0] == p[i-1].v[2])
        {
            v2 = map->vertexes[p[i].v[1]];
            v3 = map->vertexes[p[i].v[2]];
            s += sprintf(s, " %.1f,%.1f %.1f,%.1f", v2.x, v2.y, v3.x, v3.y);
        }
        else if(p[i].v[0] == p[i-1].v[0] && p[i].v[1] == p[i-1].v[2])
        {
            v3 = map->vertexes[p[i].v[2]];
            s += sprintf(s, " %.1f,%.1f", v3.x, v3.y);
        }
        else
            break;
    }
    static char color[8];
    writeColor(color, map->colors[p->color]);
    s += sprintf(s, "\" fill=\"%s\" />", color);
    //printf("%d\n", i);
    return i;
}
*/

template<typename T>
void findandreplace( T& source, const T& find, const T& replace )
{
    size_t j = 0;
    for (; (j = source.find( find, j )) != T::npos;)
    {
        source.replace( j, find.length(), replace );
        j += replace.length();
    }
}

int main()
{
    /*
        int a1, a2;
        SPolygon p1 = {0, {1, 2, 3}}, p2 = {0, {21, 31, 41}};

        int c = commonPoints(p1, p2, a1, a2);
        printf("%d\n", c);

        return 0;
    */
    /*


    SVertex a1 = {0, 0.0}, a2 = {1.0, 1.0}, b1 = {1.0, 1.0}, b2 = {2.0, 2.0};
    printf("%d\n", intersect(a1, a2, b1, b2));
    return 0;
    */

    CMap map;
    map.LoadFromFile("UI_Map.rws");
    static char xml[1024 * 1024];
    char* s = xml;

    std::string str;

    s += sprintf(
             s,
             "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n"
             "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n"
             "<svg width=\"%d\" height=\"%d\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n",
             map.header.width, map.header.height
         );


    for(int j = 0; j < map.getLayerCount(); j++)
    {
        s += sprintf(s, "<g>");
        //writePolyChain(map.layers[j]->polygons, map.layers[j]->getPolygonCount());

        groupPolygons(map.layers[j]->polygons, map.layers[j]->getPolygonCount(), map, s);
        groupLines(map.layers[j]->lines, map.layers[j]->getLineCount(), map, s);
        for(int i = 0; i < map.layers[j]->getCaptionCount(); i++)
        {
            SCaption cap = map.layers[j]->captions[i];
            static char color[10];
            static char transform[64];
            if(cap.angle == 0)
            {
                sprintf(transform, "x=\"%.1f\" y=\"%.1f\"", cap.x, cap.y);
            }
            else
            {
                sprintf(transform, "transform=\"translate(%.1f %.1f) rotate(%.1f 0 0)\"", cap.x, cap.y, -cap.angle);
            }

            static char buf[256];
            static wchar_t wbuf[256];
            int len = MultiByteToWideChar(CP_ACP, 0, map.layers[j]->names[i]->c_str(), map.layers[j]->names[i]->length(), wbuf, sizeof(wbuf));
            len = WideCharToMultiByte(CP_UTF8, 0, wbuf, len, buf, sizeof(buf), 0, 0);
            buf[len] = 0;
            std::string str;
            str.append(buf);
            findandreplace(str, std::string("&"), std::string("&amp;"));
            findandreplace(str, std::string("<"), std::string("&lt;"));
            findandreplace(str, std::string(">"), std::string("&gt;"));
            findandreplace(str, std::string("'"), std::string("&apos;"));
            findandreplace(str, std::string("\""), std::string("&quot;"));

            writeColor(color, map.colors[cap.color]);
            s += sprintf(s,
                         "<text font-weight=\"bold\" font-size=\"%.1f\" "
                         "fill=\"%s\" %s>%s</text>",
                         cap.scale, color, transform, str.c_str()
                        );
        }

        /*
        int i = 0;
        while(i < map.layers[j]->getPolygonCount())
        {
            i += writePolyChain(s, &map.layers[j]->polygons[i], map.layers[j]->getPolygonCount() - i, &map);
        }
        */
        /*
        for(int i = 0; i < map.layers[j]->getPolygonCount(); i++)
        {
            SPolygon polygon = map.layers[j]->polygons[i];
            SColor color = map.colors[polygon.color];
            SVertex v1 = map.vertexes[polygon.v[0]];
            SVertex v2 = map.vertexes[polygon.v[1]];
            SVertex v3 = map.vertexes[polygon.v[2]];
            s += writePolygon(s, v1, v2, v3, color);
        }
        for(int i = 0; i < map.layers[j]->getLineCount(); i++)
        {
            SLine line = map.layers[j]->lines[i];
            SColor color = map.colors[line.color];
            SVertex v1 = map.vertexes[line.v[0]];
            SVertex v2 = map.vertexes[line.v[1]];
            s += writeLine(s, v1.x, v1.y, v2.x, v2.y, color);
        }
        */
        s += sprintf(s, "</g>");
    }
    s += sprintf(s, "\n</svg>\n");

    FILE* f = fopen("test.xml", "w");
    fwrite(xml, 1, s - xml, f);
    fclose(f);
    //puts(xml);
    return 0;
}
