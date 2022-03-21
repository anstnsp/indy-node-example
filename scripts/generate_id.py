#!/usr/bin/python3

from plenum.common.signer_did import DidSigner
import sys

seed=sys.argv[1]
signer=DidSigner(seed=str.encode(seed))
#print('SEED : %s ' % str(signer.seed, 'UTF-8'))
print('DID : %s ' % signer.identifier)
print('verkey : %s ' % signer.verkey)
