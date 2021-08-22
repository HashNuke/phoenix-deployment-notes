run:
				docker build -t $APP_NAME . \
							--build-arg DATABASE_URL \
							--build-arg SECRET_KEY_BASE && \
				docker run -it \
  						-e DATABASE_URL \
							-e SECRET_KEY_BASE \
 							-p 4001:4001 \
 							$APP_NAME \
 							mix phx.server
