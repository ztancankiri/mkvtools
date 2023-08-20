/*
   mkvextract -- extract tracks from Matroska files into other files

   Distributed under the GPL v2
   see the file COPYING for details
   or visit https://www.gnu.org/licenses/old-licenses/gpl-2.0.html

   extracts tracks from Matroska files into other files

   Written by Moritz Bunkus <moritz@bunkus.org>.
*/

#pragma once

#include "common/common_pch.h"

#include "avilib.h"
#include "extract/xtr_base.h"

class xtr_avi_c: public xtr_base_c {
public:
  avi_t *m_avi;
  double m_fps;
  alBITMAPINFOHEADER *m_bih;
  mm_io_cptr m_out;

public:
  xtr_avi_c(const std::string &codec_id, int64_t tid, track_spec_t &tspec);

  virtual void create_file(xtr_base_c *master, libmatroska::KaxTrackEntry &track);
  virtual void handle_frame(xtr_frame_t &f);
  virtual void finish_file();

  virtual const char *get_container_name() {
    return "AVI (Microsoft Audio/Video Interleaved)";
  };
};
