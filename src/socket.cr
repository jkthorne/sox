# class Sox::Socket
#   include Socket::Server

#   def accept?
#     if client_fd = accept_impl
#       sock = Sox::Socket.new(client_fd, family, type, protocol, blocking)
#       sock.sync = sync?
#       sock
#     end
#   end
# end
