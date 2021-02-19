for n in {1..8};
do
	montage images/topic$n/*.jpg \
		-geometry 200x200+1+1  -tile x3  images/topic$n.jpg ;
done