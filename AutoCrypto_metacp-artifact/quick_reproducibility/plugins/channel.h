/**
 * Based on the blocking_tcp_echo_server.cpp from Christopher M. Kohlhoff.
 * 
 * Copyright (c) 2021 Roberto Metere <roberto@metere.it>
 * Copyright (c) 2003-2020 Christopher M. Kohlhoff (chris at kohlhoff dot com)
 * 
 * Distributed under the Boost Software License, Version 1.0. (See accompanying
 * file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
 */

#include <string>
#include <vector>

#define DEFAULT_HOST "localhost"
#define DEFAULT_PORT 10000
#define MAX_BUFFER 65536

class Channel
{
public:
  Channel(const std::string host = DEFAULT_HOST, const int port = DEFAULT_PORT);
  Channel(const int port);
  virtual ~Channel();
  
  void send(const std::string &message, const int port);
  std::string receive();
  
protected:
  std::vector<std::string> view;
  
private:
  std::string host;
  int port;
};
