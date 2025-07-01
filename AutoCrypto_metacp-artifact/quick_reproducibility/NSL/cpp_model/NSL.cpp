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
 * Description: Authenticating Two Parties
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
typedef std::string S;

class P: public std::vector<Zp>
{
public:
  P(): std::vector<Zp>() {};
  P(const char* string) {
    this->push_back(Zp(string));
  }
};

template <class T>
std::ostream& operator<<(std::ostream& ss, const std::vector<T>& x)
{
  for (size_t i = 0; i < x.size(); i++) {
    ss << (i > 0 ? "," : "") << x.at(i);
  }
  return ss;
};
// -----------------------------------------------------------------------------

class C: public std::pair<Zp, std::vector<Zp>>
{
public:
  C(): std::pair<Zp, std::vector<Zp>>() {}
  C(Zp a, std::vector<Zp>b): std::pair<Zp, std::vector<Zp>>(a, b) {}
  C(const net::Bytes &b) {
    std::string chunk = "";
    size_t i;
    
    for (i = 0; i < b.size() && b.at(i) != ','; i++) {
      chunk += b.at(i);
    }
    this->first = Zp(chunk.c_str());
    
    while (i < b.size()) {
      chunk = "";
      for (++i; i < b.size() && b.at(i) != ','; i++) {
        chunk += b.at(i);
      }
      this->second.push_back(Zp(chunk.c_str()));
    }
  }
};

template <class T, class U>
std::ostream& operator<<(std::ostream& ss, const std::pair<T, U>& p)
{
  ss << p.first << "," << p.second;
  return ss;
};
// -----------------------------------------------------------------------------
typedef Zp KP;
typedef N KS;



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
P pI;
P pR;


C aenc(const KP &kp, const P &plaintext) {
  C ciphertext;
  std::vector<Zp> encryptions;
  N ephemeralKey = groupExp.rndexp(SECURITY_PARAMETER);
  Zp s = groupExp.exp(kp, ephemeralKey);
  for (auto chunk: plaintext) {
    encryptions.push_back(groupExp.mul(chunk, s));
  }
  
  return C(groupExp.exp(groupExp.g, ephemeralKey), encryptions);
}
// -----------------------------------------------------------------------------

P adec(const KS &ks, const C &ciphertext) {
  Zp s, is;
  P plaintext;
  
  s = groupExp.exp(ciphertext.first, ks);
  is = groupExp.invmul(s);
  for (auto chunk: ciphertext.second) {
    plaintext.push_back(groupExp.mul(chunk, is));
  }
  
  return plaintext;
}
// -----------------------------------------------------------------------------

KP pk(const KS &ks) {
  return groupExp.exp(groupExp.g, ks);
}
// -----------------------------------------------------------------------------

P concat(const P &a, const P &b) {
  P ab(a);
  ab.insert(ab.end(), b.begin(), b.end());;
  return ab;
}
// -----------------------------------------------------------------------------

P fst(const P &t) {
  P f;
  
  if (t.size() < 1) {
    std::cerr << "fst(). Empty argument." << std::endl;
    std::exit(2);
  }
  f.push_back(t[0]);
  
  return f;
}
// -----------------------------------------------------------------------------

P snd(const P &t) {
  P f;
  
  if (t.size() < 2) {
    std::cerr << "snd(). Not enough elements to project." << std::endl;
    std::exit(2);
  }
  f.push_back(t[1]);
  
  return f;
}
// -----------------------------------------------------------------------------


class I
{
public:
  I(const std::string &host, KS skI, KP pkR) {
    std::stringstream message;
    this->skI = skI;
    this->pkR = pkR;

    c = new net::Channel(8615 + 'I');
    this->ni.push_back(groupExp.rndexp(SECURITY_PARAMETER));
    m1 = aenc(pkR, concat(ni, pI));
    message << m1;
    c->send(message.str(), 8615 + 'R', host);
    C m2 = C(c->receive());
    P nr = fst(snd(adec(skI, m2)));
    m3 = aenc(pkR, concat(nr, pR));
    message << m3;
    c->send(message.str(), 8615 + 'R', host);
    std::cout << "ni = " << ni << std::endl;
  };
  
  virtual ~I() {
  delete c;
};
  
private:
  P ni;
  C m1;
  C m3;
  KS skI;
  KP pkR;
  net::Channel *c;
};

class R
{
public:
  R(const std::string &host, KS skR, KP pkI) {
    std::stringstream message;
    this->skR = skR;
    this->pkI = pkI;

    c = new net::Channel(8615 + 'R');
    C m1 = C(c->receive());
    this->nr.push_back(groupExp.rndexp(SECURITY_PARAMETER));
    P ni = fst(adec(skR, m1));
    m2 = aenc(pkI, concat(ni, concat(nr, pR)));
    message << m2;
    c->send(message.str(), 8615 + 'I', host);
    C m3 = C(c->receive());
    std::cout << "ni = " << ni << std::endl;
  };
  
  virtual ~R() {
  delete c;
};
  
private:
  KP pkI;
  P nr;
  C m2;
  KS skR;
  net::Channel *c;
};


void syntax(const char* exename) {
  std::cerr << "Syntax: " << exename << " <g> <p> <pI>  <pR> <skI> <pkR> <skR> <pkI> <I|R> [remote-host]" << std::endl;
}

int main(int argc, char* argv[]) {
  std::string remoteHost;
  const int argN = 10;
  KS skI;
  KP pkR;
  KS skR;
  KP pkI;
  if (argc < argN || argc > argN + 1) {
    syntax(argv[0]);
    return 1;
  }
  
  remoteHost = (argc == argN + 1) ? argv[argN] : CHANNEL_H_DEFAULT_HOST;
  
  groupExp.g = Zp(argv[1]);
  groupExp.p = N(argv[2]);
  pI = P(argv[3]);
  pR = P(argv[4]);
  skI = KS(argv[5]);
  pkR = KP(argv[6]);
  skR = KS(argv[7]);
  pkI = KP(argv[8]);
  if (std::strcmp(argv[argN - 1], "I") == 0) { I entity(remoteHost, skI, pkR);
  } else  if (std::strcmp(argv[argN - 1], "R") == 0) { R entity(remoteHost, skR, pkI);
  } else {
    syntax(argv[0]);
    return 1;
  }

  return 0;
} // main

