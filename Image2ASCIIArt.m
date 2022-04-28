function [ imgascii ] = Image2ASCIIArt( img, gcf, filename,varargin )
% The values from low intensity to high intensity for the characters to
% use
asciis=[' .,:;irXAs253hMHGS#9B&@'];

if isempty(varargin)
    CharPixelHeight=7;
    CharPixelWidth=4;
end

NumAsciis=length(asciis);

temp=imread(img,'jpg');

imwrite(temp,'img.bmp','bmp');
img=imread('img.bmp','bmp');

% This makes the grayscale more contrasting.  So it makes the output much
% much cleaner.
img = imadjust(img, [0 1], [0 1]);

img=rgb2gray(img);
[rows, cols]=size(img);

%img=abs(hex2dec(dec2hex(img))-255);

img = 255 - double(img);

%img=reshape(img, rows, cols);

extrarows=mod(rows,CharPixelHeight);
extracols=mod(cols,CharPixelWidth);
img=img(1:(end-extrarows),1:(end-extracols));
[rows, cols] = size(img);


NumCharsHigh=rows/CharPixelHeight;
NumCharsWidth=cols/CharPixelWidth;

% What this does is effectively add up all of the cells that make up each
% of the combined boxes.
denseboxes=zeros(rows/CharPixelHeight,cols/CharPixelWidth);
for ii=1:7
    for oo=1:CharPixelWidth
        pixels=img(ii:CharPixelHeight:end,oo:CharPixelWidth:end);
        denseboxes = denseboxes + pixels;
    end
end
%gcf=2.1;
denseboxes = denseboxes - min(min(denseboxes));
denseboxes = denseboxes./max(max(denseboxes));
denseboxes = denseboxes.^gcf;


map=linspace(min(min(denseboxes)),max(max(denseboxes)),NumAsciis);


%map=max(max(denseboxes))+min(min(denseboxes))-logspace(log10(min(min(denseboxes))),log10(max(max(denseboxes))),23);
%imgascii=zeros(rows/13,cols/8);
imgascii=zeros(rows/CharPixelHeight,cols/CharPixelWidth);


for ii=1:(rows/CharPixelHeight)

    for jj=1:(cols/CharPixelWidth)
        which_char=1;
        for kk=1:numel(map)
            if denseboxes(ii,jj)>=map(kk)
                which_char=which_char+1;
            end
        end
        if(which_char>23),which_char=23; end
        imgascii(ii,jj)=asciis(which_char);
    end
end
imgascii=char(uint8(imgascii));
fid = fopen(filename, 'w');
for ii=1:size(imgascii,1)
    fprintf(fid, '%s\r\n', imgascii(ii,:));
end
fclose(fid);
end
