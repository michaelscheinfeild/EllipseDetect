function [] = plot_ellipse(detected_ellipses,img)

X0 = detected_ellipses.X0;
Y0 = detected_ellipses.Y0;
a = detected_ellipses.a;
b = detected_ellipses.b;
cos_phi = cos(detected_ellipses.phi);
sin_phi = sin(detected_ellipses.phi);

% rotation matrix to rotate the axes with respect to an angle phi
R = [ cos_phi sin_phi; -sin_phi cos_phi ];

% the axes
ver_line        = [ [X0 X0]; Y0+b*[-1 1] ];
horz_line       = [ X0+a*[-1 1]; [Y0 Y0] ];
new_ver_line    = R*ver_line;
new_horz_line   = R*horz_line;

% the ellipse
theta_r         = linspace(0,2*pi);
ellipse_x_r     = X0 + a*cos( theta_r );
ellipse_y_r     = Y0 + b*sin( theta_r );
rotated_ellipse = R * [ellipse_x_r;ellipse_y_r];

% draw
figure()
imshow(img);title(['img and detected ellipse(a,b) '  num2str(a)  '  '  num2str(b)])
hold on;
plot( new_ver_line(1,:),new_ver_line(2,:),'r' );
plot( new_horz_line(1,:),new_horz_line(2,:),'r' );
plot( rotated_ellipse(1,:),rotated_ellipse(2,:),'r' );