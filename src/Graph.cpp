#include "BlockSim.h"

SEXP BS_ShortestDistances(SEXP _Edges, SEXP _Index, SEXP _SourceNodes)
{
  PROTECT(_Edges = AS_INTEGER(_Edges));
  int *Edges = INTEGER_POINTER(_Edges);
  PROTECT(_Index = AS_INTEGER(_Index));
  int *Index = INTEGER_POINTER(_Index);
  PROTECT(_SourceNodes = AS_LOGICAL(_SourceNodes));
  int *SourceNodes = LOGICAL_POINTER(_SourceNodes);
  
  SEXP _nEdges;
  PROTECT(_nEdges = GET_DIM(_Edges));
  int nEdges = INTEGER_POINTER(AS_INTEGER(_nEdges))[0];
  int nNodes = length(_SourceNodes);
  
  SEXP _Dist;
  PROTECT(_Dist = NEW_NUMERIC(nNodes * nNodes));
  SetDim2(_Dist, nNodes, nNodes);
  double *Dist = NUMERIC_POINTER(_Dist);
  SetValues(_Dist, Dist, R_PosInf);
  
  int *queue = (int *) R_alloc(nNodes, sizeof(int));
  int queue_head, queue_tail;
  
  for (int s = 0; s < nNodes; s++)
  {
    if (!SourceNodes[s]) continue;
    
    queue_head = queue_tail = 0;
    queue[queue_tail++] = s;
    Dist[s + s * nNodes] = 0;
    
    while (queue_head != queue_tail)
    {
      int n = queue[queue_head++];
      int d = Dist[s + n * nNodes] + 1;
      
      for (int i = Index[n]; i < Index[n+1]; i++)
      {
        int t = Edges[nEdges + i] - 1;
        if (Dist[s + t * nNodes] == R_PosInf)
        {
          queue[queue_tail++] = t;
          Dist[s + t * nNodes] = d;
        }
      }
    }
  }
  
  UNPROTECT(5);
  return (_Dist);
}
