// $Id$

#ifndef _spimage_h_
#define _spimage_h_

#include <list>

#include "SpFile.h"
#include "SpImageDim.h"

class SpImage;

class SpImageFormat
{
	public:
		virtual string formatString() = 0;
		virtual SpImage* constructImage() = 0;
		virtual bool recognise(unsigned char *buf) = 0;
		virtual int sizeToRecognise() = 0;
};

class SpImage : public SpFile
{
	public:
		static SpImage* construct(const SpPath &path);
		static void registerPlugins();
		static void deRegisterPlugins();
		virtual SpImageDim dim() = 0;
		virtual bool valid() = 0;
		string formatString() { return getFormat()->formatString(); };
		SpImageFormat* getFormat() { return format; };
	private:
		static list<SpImageFormat *> plugins;
		SpImageFormat *format;
};

#endif
