## Copyright (C) 2008  David Bateman
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{s} =} spaugment (@var{a}, @var{c})
## Creates the augmented matrix of @var{a}. This is given by
##
## @example
## [@var{c} * eye(@var{m}, @var{m}),@var{a}; @var{a}', zeros(@var{n},
## @var{n})]
## @end example
##
## @noindent
## This is related to the leasted squared solution of 
## @code{@var{a} \\ @var{b}}, by
## 
## @example
## @var{s} * [ @var{r} / @var{c}; x] = [@var{b}, zeros(@var{n},
## columns(@var{b})]
## @end example
##
## @noindent
## where @var{r} is the residual error
##
## @example
## @var{r} = @var{b} - @var{a} * @var{x}
## @end example
##
## As the matrix @var{s} is symmetric indefinite it can be factorized
## with @code{lu}, and the minimum norm solution can therefore be found
## without the need for a @code{qr} factorization. As the residual
## error will be @code{zeros (@var{m}, @var{m})} for under determined
## problems, and example can be 
##
## @example
## @group
## m = 11; n = 10; mn = max(m ,n);
## a = spdiags ([ones(mn,1), 10*ones(mn,1), -ones(mn,1)],[-1,0,1], m, n);
## x0 = a \ ones (m,1);
## s = spaugment (a);
## [L, U, P, Q] = lu (s);
## x1 = Q * (U \ (L \ (P  * [ones(m,1); zeros(n,1)])));
## x1 = x1(end - n + 1 : end);
## @end group
## @end example
##
## To find the solution of an overdetermined problem needs an estimate
## of the residual error @var{r} and so it is more complex to formulate
## a minimum norm solution using the @code{spaugment} function.
##
## In general the left division operator is more stable and faster than
## using the @code{spaugment} function.
## @end deftypefn

function s = spaugment (a, c)
  if (nargin < 2)
    if (issparse (a))
      c = max (max (abs (a))) / 1000;
    else
      if (ndims (a) != 2)
	error ("spaugment: expecting 2-dimenisional matrix")
      else
	c = max (abs (a(:))) / 1000;
      endif
    endif
  elseif (!isscalar (c))
    error ("spaugment: c must be a scalar");
  endif

  [m, n] = size (a);
  s = [ c * speye(m, m), a; a', sparse(n, n)];
endfunction

%!test
%! m = 11; n = 10; mn = max(m ,n);
%! a = spdiags ([ones(mn,1), 10*ones(mn,1), -ones(mn,1)],[-1,0,1], m, n);
%! x0 = a \ ones (m,1);
%! s = spaugment (a);
%! [L, U, P, Q] = lu (s);
%! x1 = Q * (U \ (L \ (P  * [ones(m,1); zeros(n,1)])));
%! x1 = x1(end - n + 1 : end);
%! assert (x1, x0, 1e-6)
