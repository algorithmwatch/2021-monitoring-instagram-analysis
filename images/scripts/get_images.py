import os, requests, hashlib, time
import pandas as pd
import instaloader

L = instaloader.Instaloader()
L.load_session_from_file("nicolaskb")

df = pd.read_csv("data/posts_with_topics.csv")


for n in range(1,9):

	# Removes existing images from folder
	dir_path = "images/topic%d" % n
	for root, dirs, files in os.walk(dir_path):
	    for file in files:
	        os.remove(os.path.join(root, file))

	# Finds list of 20 random images from top 100 for each topic
	for i, row in df.drop_duplicates(subset=['post_short_code']).sort_values(by= [("im_top%d" % n)],ascending = False).head(100).sample(n=21).iterrows():
		
		try:
			print(row["post_short_code"])
			post = instaloader.Post.from_shortcode(L.context, row["post_short_code"])
		except Exception:
			pass
		post_url = post.url

		hash = hashlib.sha1()
		hash.update(str(time.time()).encode("UTF-8"))
		r = requests.get(post_url, allow_redirects=True)
		open('images/topic%d/%s.jpg' % (n, hash.hexdigest()), 'wb').write(r.content)