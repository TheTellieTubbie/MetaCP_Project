/**
 * Based on the blocking_tcp_echo_server.cpp from Christopher M. Kohlhoff.
 * 
 * Copyright (c) 2021 Roberto Metere <roberto@metere.it>
 * Copyright (c) 2003-2020 Christopher M. Kohlhoff (chris at kohlhoff dot com)
 * 
 * Distributed under the Boost Software License, Version 1.0. (See accompanying
 * file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
 */

#include "channel.h"
#include <iostream>
#include <utility>
#include <asio.hpp>
// -----------------------------------------------------------------------------

Channel::Channel(const int port) : Channel(DEFAULT_HOST, port) {}
// -----------------------------------------------------------------------------

Channel::Channel(const std::string host, const int port)
{
  this->host = host;
  if (port < 1 || port > 65535) {
    std::cerr << "Channel(). Port must be in the range 1-65535. Using default " << DEFAULT_PORT << "." << std::endl;
    this->port = DEFAULT_PORT;
  } else {
    this->port = port;
  }
}
// -----------------------------------------------------------------------------

Channel::~Channel() { }
// -----------------------------------------------------------------------------

void Channel::send(const std::string &message, const int port)
{
  if (message == "") {
    return; // Nothing to send
  }
  
  try {
    asio::io_context io_context;
    asio::ip::tcp::socket socket(io_context);
    asio::ip::tcp::resolver resolver(io_context);
    asio::connect(socket, resolver.resolve(this->host, std::to_string(port)));
    asio::write(socket, asio::const_buffer(message.c_str(), message.length()));
    this->view.push_back(message);
  } catch (std::exception& e) {
    std::cerr << "Channel::send(). Exception caught: " << e.what() << std::endl;
  }
}
// -----------------------------------------------------------------------------

std::string Channel::receive()
{
  char data[MAX_BUFFER];
  std::string message = "";
  size_t length;
  
  try {
    asio::io_context io_context;
    asio::ip::tcp::acceptor acceptor(io_context, asio::ip::tcp::endpoint(asio::ip::tcp::v4(), this->port));
    
    asio::ip::tcp::socket socket = acceptor.accept();
    asio::error_code error;
    length = socket.read_some(asio::buffer(data), error);
    data[MAX_BUFFER - 1] = '\0'; // Reduce buffer overflows chances?
    if (length < MAX_BUFFER) {
      data[length] = '\0'; // Manually required
    }
    message = data;
    
    if (error == asio::error::eof) {
      return 0; // Connection closed cleanly by peer.
    } else if (error) {
      throw asio::system_error(error); // Some other error.
    }
    
    this->view.push_back(message);
  } catch (std::exception& e) {
    std::cerr << "Exception: " << e.what() << "\n";
  }
  
  return message;
}
// -----------------------------------------------------------------------------

