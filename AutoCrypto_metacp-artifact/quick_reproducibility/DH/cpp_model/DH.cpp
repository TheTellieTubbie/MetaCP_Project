/**
 * This script has been automatically created by Meta-CP
 * 
 * Modeller: Meta-CP
 * Expert Refiner: |your-name-or-your-group-whatever|
 * Date: |today?|
 *
 * Dependencies:
 *  - Crypto++
 *  - Asio
 *  - C++/net/channel.cpp and C++/net/channel.h
 *    available at https://github.com/nitrogl/snippets/
 *
 * Compile hint:
 * $ c++ -O3 -Wall -c channel.cpp -o channel.o
 * $ c++ -O3 -Wall channel.o this-file.cpp -o this-file.exe -pthread -lcryptopp
 * 
 * Description: Exchange a long term secret key
 */
 
#include <iostream>
#include <sstream>
#include <cryptopp/integer.h>
#include <cryptopp/nbtheory.h>
#include <cryptopp/osrng.h>
#include "channel.h"

#define SECURITY_PARAMETER 512

typedef CryptoPP::Integer N;
typedef CryptoPP::Integer Zp;



class GroupExp {
public:
  Zp g;
  N p;
  CryptoPP::AutoSeededRandomPool rnd;
  
  N rndexp(const int securityParameter) {
    return N(this->rnd, securityParameter).Modulo(this->p);
  }
  
  Zp mul(const Zp &a, const Zp &b) const {
    return Zp(a*b).Modulo(this->p);
  }
  
  Zp invmul(const Zp &a) const {
    return a.InverseMod(this->p);
  }
  
  Zp exp(const Zp &base, const N &exponent) const {
    return CryptoPP::ModularExponentiation(base, exponent, this->p);
  }
};
GroupExp groupExp;
// -----------------------------------------------------------------------------
Zp exp(const Zp &b, const N &e) {
  return groupExp.exp(b, e);
}
// -----------------------------------------------------------------------------





class A
{
public:
  A(const std::string &host) {
    std::stringstream message;

    c = new net::Channel(16859 + 'A');
    this->x = groupExp.rndexp(SECURITY_PARAMETER);
    gx = exp(groupExp.g, x);
    message << gx;
    c->send(message.str(), 16859 + 'B', host);
    Zp gy = Zp(c->receiveText().c_str());
    kA = exp(gy, x);
    std::cout << "kA = " << kA << std::endl;
  };
  
  virtual ~A() {
  delete c;
};
  
private:
  N x;
  Zp kA;
  Zp gx;
  net::Channel *c;
};

class B
{
public:
  B(const std::string &host) {
    std::stringstream message;

    c = new net::Channel(16859 + 'B');
    Zp gx = Zp(c->receiveText().c_str());
    this->y = groupExp.rndexp(SECURITY_PARAMETER);
    gy = exp(groupExp.g, y);
    message << gy;
    c->send(message.str(), 16859 + 'A', host);
    kB = exp(gx, y);
    std::cout << "kB = " << kB << std::endl;
  };
  
  virtual ~B() {
  delete c;
};
  
private:
  N y;
  Zp kB;
  Zp gy;
  net::Channel *c;
};


void syntax(const char* exename) {
  std::cerr << "Syntax: " << exename << " <g> <p> <A|B> [remote-host]" << std::endl;
}

int main(int argc, char* argv[]) {
  std::string remoteHost;
  const int argN = 4;

  if (argc < argN || argc > argN + 1) {
    syntax(argv[0]);
    return 1;
  }
  
  remoteHost = (argc == argN + 1) ? argv[argN] : CHANNEL_H_DEFAULT_HOST;
  
  groupExp.g = Zp(argv[1]);
  groupExp.p = N(argv[2]);
  if (std::strcmp(argv[argN - 1], "A") == 0) { A entity(remoteHost);
  } else  if (std::strcmp(argv[argN - 1], "B") == 0) { B entity(remoteHost);
  } else {
    syntax(argv[0]);
    return 1;
  }

  return 0;
} // main

