QRCode
======

A command line tool to create a QR code image from a given string

Usage
-----

`QRCode -i -o [-s -t [jpg|jpeg|tif|tiff|png|bmp|gif] -e [L|M|Q|H] ]`


`-i	<input> the string to be encoded`

`-o <output> the destination image file path`

`-s <size> the image side length in Pixel (optional; default = 100)`

`-t <type> the image type (optional jpg/jpeg, tif/tiff, png, bmp, gif; default = png)`

`-e <error correction> the error correction format (optional L[=7%], M[=15%], Q[=25%], H[=30%] : default = M)`

`-help Print this help message`

System Requirements
-------------------

Mac OS 10.9 Mavericks or higher

Xcode 6