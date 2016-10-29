#include "image.h"

inline SFloatColor ColorTrueToFloat(STrueColor color){
	SFloatColor ret;
	ret.r = (float)color.r / 255.0f;
	ret.g = (float)color.g / 255.0f;
	ret.b = (float)color.b / 255.0f;
	ret.a = (float)color.a / 255.0f;
	return ret;
}

inline SFloatColor ColorGBAToFloat(SGBAColor color){
	SFloatColor ret;
	ret.r = (float)color.r / 31.0f;
	ret.g = (float)color.g / 31.0f;
	ret.b = (float)color.b / 31.0f;
	ret.a = (float)color.a / 1.0f;
	return ret;
}

inline STrueColor ColorFloatToTrue(SFloatColor color){
	STrueColor ret;
	ret.r = color.r * 255.0f + 0.5f;
	ret.g = color.g * 255.0f + 0.5f;
	ret.b = color.b * 255.0f + 0.5f;
	ret.a = color.a * 255.0f + 0.5f;
	return ret;
}

inline SGBAColor ColorFloatToGBA(SFloatColor color){
	SGBAColor ret;
	ret.r = color.r * 31.0f + 0.5f;
	ret.g = color.g * 31.0f + 0.5f;
	ret.b = color.b * 31.0f + 0.5f;
	ret.a = color.a * 1.0f  + 0.5f;
	return ret;
}

inline STrueColor ColorGBAToTrue(SGBAColor color){
	return ColorFloatToTrue(ColorGBAToFloat(color));
}

inline SGBAColor ColorTrueToGBA(STrueColor color){
	return ColorFloatToGBA(ColorTrueToFloat(color));
}

void decodeImage(void *in, void* out, int& width, int& height, int _alpha){
	SGBAColor  *gba_color  = (SGBAColor*)in + 2;
	STrueColor *true_color = (STrueColor*)out;
	width  = *(short*)in;
	height = *((short*)in + 1);
	for(int i = 0; i < width * height; i++){
		*true_color = ColorGBAToTrue(*gba_color);
                if(!_alpha) true_color->a = 255;
		true_color++;
		gba_color++;
	}

        if(!_alpha) return;
	unsigned char *alpha = (unsigned char*)gba_color;
	true_color = (STrueColor*)out;
	for(int i = 0; i < width * height; i++){
        	true_color->a = *alpha;
                alpha++;
		true_color++;
	}
}

int detectAlpha(int width, int height, void* data){
    STrueColor *c = (STrueColor*)data;
    for(int i = 0; i < width * height; i++){
        if(c->a < 255){
            return 1;
        }
    }
    return 0;
}

int encodeImage(void *in, void* out, int width, int height, int _alpha){
	SGBAColor  *gba_color  = (SGBAColor*)out + 2;
	STrueColor *true_color = (STrueColor*)in;
	*(short*)out = width;
	*((short*)out + 1) = height;
	for(int i = 0; i < width * height; i++){
		*gba_color = ColorTrueToGBA(*true_color);
                gba_color->a = 1;
		true_color++;
		gba_color++;
	}

        if(_alpha == -1) _alpha = detectAlpha(width, height, in);

        if(!_alpha){
                return (unsigned int)gba_color - (unsigned int)out;
        }
	unsigned char *alpha = (unsigned char*)gba_color;
	true_color = (STrueColor*)in;
	for(int i = 0; i < width * height; i++){
        	*alpha = true_color->a;
                alpha++;
		true_color++;
	}
        return (unsigned int)alpha - (unsigned int)out;
}
