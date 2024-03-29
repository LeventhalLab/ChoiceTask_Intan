function pp = slm2pp(slm)
% slm2pp: converts a piecewise hermite ('slm') form into a pp form
% 
% arguments: (input)
%  slm - a hermite form ('slm') piecewise function, probably
%         generated by slmengine or slmfit, usable by slmeval
%
%         Must be a model of degree 0, 1, 3, 5 or 7.
%
% arguments: (output)
%  pp   - a piecewise function, usable by ppval, etc.
%
% Example usage:
%  pp = slm2pp(slm);
%
%
% See also: slmset, slmengine, slmeval, ppval
%
%
% Author: John D'Errico
% E-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 1/14/07

% error checks are simple
if nargin<1
  help slm2pp
  return
elseif (nargin>1) || ~isstruct(slm) || ~strcmp(slm.form,'slm')
  error 'slm2pp takes only 1 argument, a struct, of form ''slm'''
end

% make the pp form
pp.form = 'pp';
pp.breaks = slm.knots(:)';
nbr = length(slm.knots);
degree = slm.degree;

ind = 1:(nbr-1);
switch degree
  case {0 'constant'}
    pp.coefs = slm.coef;
  case {1 'linear'}
    c0 = slm.coef(ind,1);
    c1 = diff(slm.coef)./diff(slm.knots);
    pp.coefs = [c1,c0];
  case {3 'cubic'}
    dx = diff(slm.knots);
    c0 = slm.coef(ind,1);
    c1 = slm.coef(ind,2);
    c2 = (3*(-slm.coef(ind,1) + slm.coef(ind+1,1))./dx ...
         - 2*slm.coef(ind,2) - slm.coef(ind+1,2))./dx;
    c3 = ((2*slm.coef(ind,1) - 2*slm.coef(ind+1,1))./dx ...
         + slm.coef(ind,2) + slm.coef(ind+1,2))./(dx.^2);
    pp.coefs = [c3,c2,c1,c0];
  case {5 'quintic'}
    % 5th order spline
    dx = diff(slm.knots);
    c0 = slm.coef(ind,1);
    c1 = slm.coef(ind,2);
    c2 = slm.coef(ind,3)/2;
    
    pp.coefs = zeros(nbr-1,6);
    pp.coefs(:,6) = c0;
    pp.coefs(:,5) = c1;
    pp.coefs(:,4) = c2;
    for i = 1:(nbr - 1)
      dxi = dx(i);
      % formulate a linear system of equations in the coefficients
      % of the segment polynomial to determine the higher order
      % coefficients of the polynomial.
      A = [dxi.^[5 4 3];[5 4 3].*dxi.^[4 3 2];[20 12 6].*dxi.^[3 2 1]];
      rhs = slm.coef(i+1,:)' - ...
        [dxi.^[2 1 0];[2 1 0].*dxi.^[1 0 0];[2 0 0].*dxi.^[0 0 0]]* ...
        pp.coefs(i,4:6).';
      
      pp.coefs(i,1:3) = (A\rhs).';
    end
  case 7
    % 7th order spline (heptic?)
    dx = diff(slm.knots);
    pp.coefs = [zeros(nbr-1,4),slm.coef(ind,4)/6, ...
      slm.coef(ind,3)/2,slm.coef(ind,2),slm.coef(ind,1)];
    
    for i = 1:(nbr - 1)
      dxi = dx(i);
      % formulate a linear system of equations in the coefficients
      % of the segment polynomial to determine the higher order
      % coefficients of the polynomial.
      A = [dxi.^[7 6 5 4 3 2 1 0]; ...
        [7 6 5 4 3 2 1 0].*dxi.^[6 5 4 3 2 1 0 0]; ...
        [42 30 20 12 6 2 0 0].*dxi.^[5 4 3 2 1 0 0 0]; ...
        [210 120 60 24 6 0 0 0].*dxi.^[4 3 2 1 0 0 0 0]];
        
      rhs = slm.coef(i,:).' - A(:,5:8)*pp.coefs(i,5:8).';
      
      pp.coefs(i,1:4) = (A(:,1:4)\rhs).';
    end
    
  otherwise
    error('SLM2PP:modelorder','Sorry. I''ve only implemented up to 7th degree models here.')
end

pp.pieces = nbr - 1;
pp.order = degree + 1;
pp.dim = 1;

% also bring over the prescription as documentation
if isfield(slm,'prescription')
  pp.prescription = slm.prescription;
end



