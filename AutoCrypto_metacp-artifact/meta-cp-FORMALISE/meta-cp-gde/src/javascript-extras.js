/**
 * Author: Roberto Metere
 * Project: MetaCP
 * 
 * This file contains extra javascript functions complementing some
 * of the already existing functionalities
 * 
 * ----------------------------------------------------------------- */

export function arrayContains(arr, el) {
  if (arr != null && Array.isArray(arr)) {
    return (arr.findIndex((e) => { return e === el; })) !== -1;
  } else {
    return false;
  }
}
/* ----------------------------------------------------------------- */
