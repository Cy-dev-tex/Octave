########################################################################
##
## Copyright (C) 2019-2020 The Octave Project Developers
##
## See the file COPYRIGHT.md in the top-level directory of this
## distribution or <https://octave.org/copyright/>.
##
## This file is part of Octave.
##
## Octave is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <https://www.gnu.org/licenses/>.
##
########################################################################

## -*- texinfo -*-
## @deftypefn  {} {} streamtube (@var{x}, @var{y}, @var{z}, @var{u}, @var{v}, @var{w}, @var{sx}, @var{sy}, @var{sz})
## @deftypefnx {} {} streamtube (@var{u}, @var{v}, @var{w}, @var{sx}, @var{sy}, @var{sz})
## @deftypefnx {} {} streamtube (@var{vertices}, @var{x}, @var{y}, @var{z}, @var{u}, @var{v}, @var{w})
## @deftypefnx {} {} streamtube (@dots{}, @var{options})
## @deftypefnx {} {} streamtube (@var{hax}, @dots{})
## @deftypefnx {} {@var{h} =} streamtube (@dots{})
## Calculate and display streamtubes.
##
## Streamtubes are approximated by connecting circular crossflow areas
## along a streamline.  The expansion of the flow is determined by the local
## crossflow divergence.
##
## The vector field is given by @code{[@var{u}, @var{v}, @var{w}]} and is
## defined over a rectangular grid given by @code{[@var{x}, @var{y}, @var{z}]}.
## The streamtubes start at the seed points
## @code{[@var{sx}, @var{sy}, @var{sz}]}.
##
## The tubes are colored based on the local vector field strength.
##
## The input parameter @var{options} is a 2-D vector of the form
## @code{[@var{scale}, @var{n}]}.  The first parameter scales the start radius
## of the streamtubes (default 1).  The second parameter specifies the number
## of patches used for the streamtube circumference (default 20).
##
## @code{streamtube} can be called with a cell array containing pre-computed
## streamline data.  To do this, @var{vertices} must be created with the
## @code{stream3} function.  This option is useful if you need to alter the
## integrator step size or the maximum number of vertices of the streamline.
##
## If the first argument @var{hax} is an axes handle, then plot into this axes,
## rather than the current axes returned by @code{gca}.
##
## The optional return value @var{h} is a graphics handle to the patch plot
## objects created for each streamtube.
##
## Example:
##
## @example
## @group
## [x, y, z] = meshgrid (-1:0.1:1, -1:0.1:1, -3:0.1:0);
## u = -x / 10 - y;
## v = x - y / 10;
## w = - ones (size (x)) / 10;
## streamtube (x, y, z, u, v, w, 1, 0, 0);
## @end group
## @end example
##
## @seealso{stream3, streamline}
## @end deftypefn

## Reference:
##
## @inproceedings{
##    title = {Visualization of 3-D vector fields - Variations on a stream},
##    author = {Dave Darmofal and Robert Haimes},
##    year = {1992}
## }

function h = streamtube (varargin)

  [hax, varargin, nargin] = __plt_get_axis_arg__ ("streamtube", varargin{:});

  options = [];
  xyz = [];
  switch (nargin)
    case 0
      print_usage ();
    case 6
      [u, v, w, spx, spy, spz] = varargin{:};
      [m, n, p] = size (u);
      [x, y, z] = meshgrid (1:n, 1:m, 1:p);
    case 7
      if (iscell (varargin{1}))
        [xyz, x, y, z, u, v, w] = varargin{:};
      else
        [u, v, w, spx, spy, spz, options] = varargin{:};
        [m, n, p] = size (u);
        [x, y, z] = meshgrid (1:n, 1:m, 1:p);
      endif
    case 8
      [xyz, x, y, z, u, v, w, options] = varargin{:};
    case 9
      [x, y, z, u, v, w, spx, spy, spz] = varargin{:};
    case 10
      [x, y, z, u, v, w, spx, spy, spz, options] = varargin{:};
    otherwise
      error ("streamtube: invalid number of inputs");
  endswitch

  scale = 1;
  num_poly = 20;
  if (! isempty (options))
    switch (numel (options))
      case 1
        scale = options(1);
      case 2
        scale = options(1);
        num_poly = options(2);
      otherwise
        error ("streamtube: invalid number of OPTIONS elements");
    endswitch

    if (! isreal (scale) || scale <= 0)
      error ("streamtube: SCALE must be a real scalar > 0");
    endif
    if (! isreal (num_poly) || num_poly < 3)
      error ("streamtube: number of polygons N must be greater than 2");
    endif
    num_poly = fix (num_poly);
  endif

  if (isempty (hax))
    hax = gca ();
  else
    hax = hax(1);
  endif

  if (isempty (xyz))
    xyz = stream3 (x, y, z, u, v, w, spx, spy, spz, 0.5);
  endif

  div = divergence (x, y, z, u, v, w);
  vn = sqrt (u.*u + v.*v + w.*w);
  vmax = max (vn(:));
  vmin = min (vn(:));

  ## Radius estimator
  [ny, nx, nz] = size (x);
  dx = (max (x(:)) - min (x(:))) / nx;
  dy = (max (y(:)) - min (y(:))) / ny;
  dz = (max (z(:)) - min (z(:))) / nz;
  rstart = scale * sqrt (dx*dx + dy*dy + dz*dz);

  h = [];
  for i = 1 : length (xyz)
    sl = xyz{i};
    num_vertices = rows (sl);
    if (! isempty (sl) && num_vertices > 2)

      div_sl = interp3 (x, y, z, div, sl(:, 1), sl(:, 2), sl(:, 3));
      usl = interp3 (x, y, z, u, sl(:, 1), sl(:, 2), sl(:, 3));
      vsl = interp3 (x, y, z, v, sl(:, 1), sl(:, 2), sl(:, 3));
      wsl = interp3 (x, y, z, w, sl(:, 1), sl(:, 2), sl(:, 3));
      vv = sqrt (usl.*usl + vsl.*vsl + wsl.*wsl);

      htmp = plottube (hax, sl, div_sl, vv, vmax, vmin, rstart, num_poly);
      h = [h; htmp];

    endif
  endfor

endfunction

function h = plottube (hax, sl, div_sl, vv, vmax, vmin, rstart, num_poly)

  is_singular_div = find (isnan (div_sl), 1, "first");
  if (! isempty (is_singular_div))
    max_vertices = is_singular_div - 1;
  else
    max_vertices = length (sl);
  endif
  if (max_vertices < 3)
    error ("streamtube: too little data to plot");
  endif

  if (vmax == vmin)
    colscale = 0.0;
  else
    colscale = 1.0 / (vmax - vmin);
  endif

  phi = linspace (0, 2*pi, num_poly);
  cp = cos (phi);
  sp = sin (phi);

  X0 = sl(1, :);
  X1 = sl(2, :);

  ## 1st rotation axis
  R = X1 - X0;
  RE = R / norm (R);

  ## Initial radius
  vold = vv(1);
  vact = vv(2);
  ract = rstart * exp (0.5 * div_sl(2) * norm (R) / vact) * sqrt (vold / vact);
  vold = vact;
  rold = ract;

  ## Guide point and its rotation to create a segment
  N = get_normal1 (R);
  K = ract * N;
  XS = rotation (K, RE, cp, sp) + repmat (X1.', 1, num_poly);

  px = zeros (4, num_poly * (max_vertices - 2));
  py = zeros (4, num_poly * (max_vertices - 2));
  pz = zeros (4, num_poly * (max_vertices - 2));
  pc = zeros (4, num_poly * (max_vertices - 2));

  for i = 3 : max_vertices

    KK = K;
    X0 = X1;
    X1 = sl(i, :);
    R = X1 - X0;
    RE = R / norm (R);

    ## Tube radius
    vact = vv(i);
    ract = rold * exp (0.5 * div_sl(i) * norm (R) / vact) * sqrt (vold / vact);
    vold = vact;
    rold = ract;

    ## Project K onto RE and get the difference in order to calculate the next
    ## guiding point
    Kp = KK - RE * dot (KK, RE);
    K = ract * Kp / norm (Kp);

    XSold = XS;
    ## Rotate the guiding point around R and collect patch vertices
    XS = rotation (K, RE, cp, sp) + repmat (X1.', 1, num_poly);
    [tx, ty, tz] = segment_patch_data (XS, XSold);

    from = (i - 3) * num_poly + 1;
    to = (i + 1 - 3) * num_poly;
    px(:, from:to) = tx;
    py(:, from:to) = ty;
    pz(:, from:to) = tz;
    pc(:, from:to) = colscale * (vact - vmin) * ones (4, num_poly);

  endfor

  h = patch (hax, px, py, pz, pc);

endfunction

## Arbitrary N normal to X
function N = get_normal1 (X)

  if ((X(3) == 0) && (X(1) == -X(2)))
    N = [- X(2) - X(3), X(1), X(1)];
  else
    N = [X(3), X(3), - X(1) - X(2)];
  endif

  N /= norm (N);

endfunction

## Create patch data to draw a segment
## from starting point XS to ending point XE
function [px, py, pz] = segment_patch_data (XS, XE)

  num_poly = columns (XS);

  px = zeros (4, num_poly);
  py = zeros (4, num_poly);
  pz = zeros (4, num_poly);

  px(1, :) = XS(1, :);
  px(2, :) = XE(1, :);
  px(3, :) = [XE(1, 2:end), XE(1, 1)];
  px(4, :) = [XS(1, 2:end), XS(1, 1)];

  py(1, :) = XS(2, :);
  py(2, :) = XE(2, :);
  py(3, :) = [XE(2, 2:end), XE(2, 1)];
  py(4, :) = [XS(2, 2:end), XS(2, 1)];

  pz(1, :) = XS(3, :);
  pz(2, :) = XE(3, :);
  pz(3, :) = [XE(3, 2:end), XE(3, 1)];
  pz(4, :) = [XS(3, 2:end), XS(3, 1)];

endfunction

## Rotate X around U where |U| = 1
## cp = cos (angle), sp = sin (angle)
function Y = rotation (X, U, cp, sp)

  ux = U(1);
  uy = U(2);
  uz = U(3);

  Y(1, :) = X(1) * (cp + ux * ux * (1 - cp)) + ...
            X(2) * (ux * uy * (1 - cp) - uz * sp) + ...
            X(3) * (ux * uz * (1 - cp) + uy * sp);

  Y(2, :) = X(1) * (uy * ux * (1 - cp) + uz * sp) + ...
            X(2) * (cp + uy * uy * (1 - cp)) + ...
            X(3) * (uy * uz * (1 - cp) - ux * sp);

  Y(3, :) = X(1) * (uz * ux * (1 - cp) - uy * sp) + ...
            X(2) * (uz * uy * (1 - cp) + ux * sp) + ...
            X(3) * (cp + uz * uz * (1 - cp));

endfunction


%!demo
%! clf;
%! [x, y, z] = meshgrid (-1:0.1:1, -1:0.1:1, -3.5:0.1:0);
%! a = 0.1;
%! b = 0.1;
%! u = - a * x - y;
%! v = x - a * y;
%! w = - b * ones (size (x));
%! sx = 1.0;
%! sy = 0.0;
%! sz = 0.0;
%! streamtube (x, y, z, u, v, w, sx, sy, sz, [1.2, 30]);
%! colormap (jet);
%! shading interp;
%! view ([-47, 24]);
%! camlight ();
%! lighting gouraud;
%! grid on;
%! view (3);
%! axis equal;
%! set (gca, "cameraviewanglemode", "manual");
%! title ("Spiral Sink");

%!demo
%! clf;
%! [x, y, z] = meshgrid (-2:0.5:2);
%! t = sqrt (1.0./(x.^2 + y.^2 + z.^2)).^3;
%! u = - x.*t;
%! v = - y.*t;
%! w = - z.*t;
%! [sx, sy, sz] = meshgrid (-2:4:2);
%! xyz = stream3 (x, y, z, u, v, w, sx, sy, sz, [0.1, 60]);
%! streamtube (xyz, x, y, z, u, v, w, [2, 50]);
%! colormap (jet);
%! shading interp;
%! view ([-47, 24]);
%! camlight ();
%! lighting gouraud;
%! grid on;
%! view (3);
%! axis equal;
%! set (gca, "cameraviewanglemode", "manual");
%! title ("Integration Towards Sink");

## Test input validation
%!error streamtube ()
%!error <invalid number of inputs> streamtube (1)
%!error <invalid number of inputs> streamtube (1,2)
%!error <invalid number of inputs> streamtube (1,2,3)
%!error <invalid number of inputs> streamtube (1,2,3,4)
%!error <invalid number of inputs> streamtube (1,2,3,4,5)
%!error <invalid number of OPTIONS> streamtube (1,2,3,4,5,6, [1,2,3])
%!error <SCALE must be a real scalar . 0> streamtube (1,2,3,4,5,6, [1i])
%!error <SCALE must be a real scalar . 0> streamtube (1,2,3,4,5,6, [0])
%!error <N must be greater than 2> streamtube (1,2,3,4,5,6, [1, 1i])
%!error <N must be greater than 2> streamtube (1,2,3,4,5,6, [1, 2])
