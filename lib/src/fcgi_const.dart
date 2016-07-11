library dart_fpm.fcgi_const;

/*
 * Listening socket file number
 */
const FCGI_LISTENSOCK_FILENO = 0;

/*
 * Number of bytes in a FCGI_Header.  Future versions of the protocol
 * will not reduce this number.
 */
const FCGI_HEADER_LEN = 8;

/*
 * Value for version component of FCGI_Header
 */
const FCGI_VERSION_1 = 1;

/*
 * Values for type component of FCGI_Header are represented as enum constants
 */

/*
 * Value for requestId component of FCGI_Header
 */
const FCGI_NULL_REQUEST_ID = 0;

/*
 * Mask for flags component of FCGI_BeginRequestBody
 */
const FCGI_KEEP_CONN = 1;

/*
 * Values for role component of FCGI_BeginRequestBody are represented as enum constants
 */

/*
 * Values for protocolStatus component of FCGI_EndRequestBody are represented as enum constants
 */

/*
 * Variable names for FCGI_GET_VALUES / FCGI_GET_VALUES_RESULT records
 */
const FCGI_MAX_CONNS  = "FCGI_MAX_CONNS";
const FCGI_MAX_REQS   = "FCGI_MAX_REQS";
const FCGI_MPXS_CONNS = "FCGI_MPXS_CONNS";