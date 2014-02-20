/*

Copyright (C) 2011-2014 Michael Goffioul

This file is part of Octave.

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

#ifndef __QtHandles_PushButtonControl__
#define __QtHandles_PushButtonControl__ 1

#include "ButtonControl.h"

class QPushButton;

//////////////////////////////////////////////////////////////////////////////

namespace QtHandles
{

//////////////////////////////////////////////////////////////////////////////

class PushButtonControl : public ButtonControl
{
public:
  PushButtonControl (const graphics_object& go, QPushButton* btn);
  ~PushButtonControl (void);

  static PushButtonControl* create (const graphics_object& go);

protected:
  void update (int pId);
};

//////////////////////////////////////////////////////////////////////////////

}; // namespace QtHandles

//////////////////////////////////////////////////////////////////////////////

#endif
