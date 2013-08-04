#if 0

#include "WiiStream.h"
#include "ImageStream.h"
#include "FileStream.h"
#include <memory>

namespace Consolgames
{

WiiStream::WiiStream(const char* filename)
	: m_disc(new WiiDisc(NULL))
{
    m_position = 0;
	m_partition = 0;
    m_image = m_disc->image_init(filename);
    m_disc->image_parse(m_image);
    m_node = m_disc->m_pParent->FindDataPartition();
    m_dataPartitionIndex = node->data.part;
}

WiiStream::~WiiStream()
{
	m_disc->image_deinit(pImage);
}

void WiiStream::setPartition(int partition)
{
	ASSERT(partition >= 0 && partition < m_image->nparts);

	m_partition = partition;
	m_position = 0;
}

bool WiiStream::seekToFile(const char* path)
{
    if (m_dataPartitionIndex < 0 || m_dataPartitionIndex >= m_image->PartitionCount)
    {
        return false;
    }
    return false;
}

void WiiStream::reparse()
{
    int fp = pImage->fp;
    m_disc->image_deinit(pImage, false);
    delete pImage;

    m_disc->Reset();
    m_disc->m_pParent->ClearTree();

    pImage = m_disc->image_init(0, fp);
    m_disc->image_parse(pImage);
}

/*

void CWIIScrubberDlg::ParseDiscDetails()
{
	// load file
	if (TRUE==m_bISOLoaded)
	{
		// free the old one first
		// cleanup
		pcWiiDisc->image_deinit(pImageFile);
	}
	pcWiiDisc->Reset();
	pImageFile = pcWiiDisc->image_init(csFileName);
	if (NULL!=pImageFile)
	{
		m_bISOLoaded = TRUE;
		m_cbLISTLOG.DeleteAllItems();
		m_cbDISCFILES.DeleteAllItems();

		pcWiiDisc->image_parse(pImageFile);

		m_cbDISCFILES.Expand(m_cbDISCFILES.GetFirstVisibleItem(), TVE_EXPAND);

		uint64 nTestCase;

		nTestCase = (uint64) pcWiiDisc->CountBlocksUsed();

		nTestCase *= (uint64)(0x8000);

		// now if the headers button is clicked we need to add on the 1/32k per unmarked cluster

		if (0==m_nHEADEROPTIONS)
		{
			nTestCase = nTestCase + ((pcWiiDisc->nImageSize - nTestCase)/32);
		}

		CString csTemp;

		csTemp.Format("Disc Data Size (%I64u) approx  %I64u MB", nTestCase, nTestCase/(1024 * 1024));
		AddToLog(csTemp);

		// find out the partition with data in
		unsigned int x = 0;

		while (x < pImageFile->nparts)
		{
			if (PART_DATA == pImageFile->parts[x].type)
			{
				break;
			}
			x ++;
		}

		if (x==pImageFile->nparts)
		{
			// error as we have no data here?

		}
		else
		{
			// save the active partition info
			m_nActivePartition = x;
			// now clear out the junk data in the name
			for (int i=0; i< 0x60; i++)
			{
				if (0==isprint((int) pImageFile->parts[x].header.name[i]))
				{
					pImageFile->parts[x].header.name[i] = ' ';
				}

			}


			m_csGAMENAME = pImageFile->parts[x].header.name;
			m_csGAMESIZE = csTemp;

			csTemp.Format("Number of Files: %I64u", pImageFile->nfiles);
			m_csNUMBEROFFILES = csTemp;

			switch(pImageFile->parts[x].header.region)
			{
			case 'P':
				csTemp = "Region Code: PAL";
				break;
			case 'E':
				csTemp = "Region Code: NTSC";
				break;
			case 'J':
				csTemp = "Region Code: JAP";
				break;
			default:
				// unknown or not quite right
				csTemp.Format("Region Code: '%c'?", pImageFile->parts[x].header.region);
				break;
			}
			m_csREGIONCODE = csTemp;

			m_cbCLEANISO.EnableWindow(TRUE);

			UpdateData(FALSE);
		}
	}
	else
	{
		m_bISOLoaded = FALSE;
		AddToLog("Error on load");
	}

}
*/

int WiiStream::read(void* buf, off64_t size)
{
    char* ptr = (char*)buf;
    uint32 cache_size = 0, cache_offset = (uint32)(pos % (uint64)(0x7c00)), _size;
    uint32 block = (uint32)(pos / (uint64)(0x7c00));
    size = std::min((__int64)(pImage->parts[part].data_size - pos), (__int64)size);
    if (!pImage->parts[part].is_encrypted)
    {
        if (lseek(pImage->fp, pos, SEEK_SET) == -1)
        {
            return -1;
        }
        ::_read(pImage->fp, buf, size);
        pos += cache_size;
        return size;
    }
    else
    {
        _size = size;
        while (size)
        {
            if (m_disc->decrypt_block(pImage, part, block))
            {
                return false;
            }
            cache_size = size;
            if (cache_size + cache_offset > 0x7c00)
            {
                cache_size = 0x7c00 - cache_offset;
            }
            memcpy(ptr, pImage->parts[part].cache + cache_offset, cache_size);
            size -= cache_size;
            ptr += cache_size;
            pos += cache_size;
            cache_offset = 0;
            block++;
        }
        return _size;
    }
    return 0;
}

int WiiStream::write(void* buf, int size)
{
    return 0;
}


int WiiStream::partition() const
{
	return m_partition;
}

int WiiStream::dataPartition()
{
	return m_dataPartitionIndex;
}

bool WiiStream::setDataPartition()
{
	return setPartition(m_dataPartitionIndex);
}

offset_t WiiStream::tell() const
{
	return m_position;
}

offset_t WiiStream::seek(offset_t offset, SeekOrigin origin)
{
	switch(origin)
	{
	case seekSet:
		m_position = offset;
		break;
	case seekCur:
		m_position += offset;
		break;
	case seekEnd:
		m_position = stream_size + offset;
		break;
	}
	return m_position;
}

void WiiStream::flush()
{
}

WiiDisc WiiStream::disc()
{
	return m_disc;
}

ImageFile* WiiStream::image()
{
	return pImage;
}

virtual largesize_t WiiStream::size() const override
{
	return m_streamSize;
}

ImageFileStream* WiiStream::findFile(const char* filename)
{
    PNode node = m_disc->m_pParent->findFile(m_disc->m_pParent->FindDataPartition(), filename);
    return node ? (ImageFileStream*)(new WiiFileStream(this, node->data.part, node->data.offset, node->data.size)) : 0;
}


int WiiFileStream::read(void* buf, int size)
{
    int t_part = m_stream->getPartition();
    __int64 t_pos = m_stream->tell();
    m_stream->setPartition(m_partition);
    m_stream->seek(m_offset + m_postition, 0);
    int s_size =  std::min((__int64)size, m_fileSize - m_postition);
    int ret = m_stream->read(buf, s_size);
    m_postition += ret;
    m_stream->setPartition(t_part);
    m_stream->seek(t_pos, 0);
    return ret;
}
int WiiFileStream::write(void* buf, int size)
{
    return 0;
}


WiiFileStream::WiiFileStream(WiiStream *wii_stream, int partition, offset_t offset, largesize_t size)
{
	m_stream = wii_stream;
	m_postition = 0;
	m_fileSize   = size;
	m_offset = offset;
	m_partition = partition;
}

WiiFileStream::~WiiFileStream()
{
}

offset_t WiiFileStream::seek(offset_t offset, SeekOrigin origin)
{
	switch(origin)
	{
	case seekSet: m_postition = offset;  break;
	case seekCur: m_postition += offset; break;o
	case seekEnd: m_postition = m_fileSize + offset; break;
	}
	return m_postition;
}

offset_t WiiFileStream::tell() const
{
	return m_postition;
}

void WiiFileStream::flush()
{
}

largesize_t WiiFileStream::size() const
{
	return m_fileSize;
}

bool WiiFileStream::opened() const
{
	return m_stream != NULL;
}

ImageFileStream* WiiFileStream::findFile(const char* filename)
{
	return NULL;
}

}

#endif