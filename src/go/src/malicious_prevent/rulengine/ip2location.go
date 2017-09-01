package rulengine

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"math/big"
	"net"
	"os"
	"strconv"
)

type ip2locationmeta struct {
	databasetype      uint8
	databasecolumn    uint8
	databaseday       uint8
	databasemonth     uint8
	databaseyear      uint8
	ipv4databasecount uint32
	ipv4databaseaddr  uint32
	ipv6databasecount uint32
	ipv6databaseaddr  uint32
	ipv4indexbaseaddr uint32
	ipv6indexbaseaddr uint32
	ipv4columnsize    uint32
	ipv6columnsize    uint32
}

type IP2Locationrecord struct {
	Country_short      string
	Country_long       string
	Region             string
	City               string
	Isp                string
	Latitude           float32
	Longitude          float32
	Domain             string
	Zipcode            string
	Timezone           string
	Netspeed           string
	Iddcode            string
	Areacode           string
	Weatherstationcode string
	Weatherstationname string
	Mcc                string
	Mnc                string
	Mobilebrand        string
	Elevation          float32
	Usagetype          string
}

var f *os.File
var meta ip2locationmeta

var country_position = [25]uint8{0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
var region_position = [25]uint8{0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}
var city_position = [25]uint8{0, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4}
var isp_position = [25]uint8{0, 0, 3, 0, 5, 0, 7, 5, 7, 0, 8, 0, 9, 0, 9, 0, 9, 0, 9, 7, 9, 0, 9, 7, 9}
var latitude_position = [25]uint8{0, 0, 0, 0, 0, 5, 5, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5}
var longitude_position = [25]uint8{0, 0, 0, 0, 0, 6, 6, 0, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6}
var domain_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 6, 8, 0, 9, 0, 10, 0, 10, 0, 10, 0, 10, 8, 10, 0, 10, 8, 10}
var zipcode_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 0, 7, 7, 7, 0, 7, 0, 7, 7, 7, 0, 7}
var timezone_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 7, 8, 8, 8, 7, 8, 0, 8, 8, 8, 0, 8}
var netspeed_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 11, 0, 11, 8, 11, 0, 11, 0, 11, 0, 11}
var iddcode_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 12, 0, 12, 0, 12, 9, 12, 0, 12}
var areacode_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 13, 0, 13, 0, 13, 10, 13, 0, 13}
var weatherstationcode_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 14, 0, 14, 0, 14, 0, 14}
var weatherstationname_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 15, 0, 15, 0, 15, 0, 15}
var mcc_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 16, 0, 16, 9, 16}
var mnc_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 17, 0, 17, 10, 17}
var mobilebrand_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 18, 0, 18, 11, 18}
var elevation_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11, 19, 0, 19}
var usagetype_position = [25]uint8{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 20}

const api_version string = "8.0.3"

var max_ipv4_range = big.NewInt(4294967295)
var max_ipv6_range = big.NewInt(0)

const countryshort uint32 = 0x00001
const countrylong uint32 = 0x00002
const region uint32 = 0x00004
const city uint32 = 0x00008
const isp uint32 = 0x00010
const latitude uint32 = 0x00020
const longitude uint32 = 0x00040
const domain uint32 = 0x00080
const zipcode uint32 = 0x00100
const timezone uint32 = 0x00200
const netspeed uint32 = 0x00400
const iddcode uint32 = 0x00800
const areacode uint32 = 0x01000
const weatherstationcode uint32 = 0x02000
const weatherstationname uint32 = 0x04000
const mcc uint32 = 0x08000
const mnc uint32 = 0x10000
const mobilebrand uint32 = 0x20000
const elevation uint32 = 0x40000
const usagetype uint32 = 0x80000

const all uint32 = countryshort | countrylong | region | city | isp | latitude | longitude | domain | zipcode | timezone | netspeed | iddcode | areacode | weatherstationcode | weatherstationname | mcc | mnc | mobilebrand | elevation | usagetype

const invalid_address string = "Invalid IP address."
const missing_file string = "Invalid database file."
const not_supported string = "This parameter is unavailable for selected data file. Please upgrade the data file."

var metaok bool

var country_position_offset uint32
var region_position_offset uint32
var city_position_offset uint32
var isp_position_offset uint32
var domain_position_offset uint32
var zipcode_position_offset uint32
var latitude_position_offset uint32
var longitude_position_offset uint32
var timezone_position_offset uint32
var netspeed_position_offset uint32
var iddcode_position_offset uint32
var areacode_position_offset uint32
var weatherstationcode_position_offset uint32
var weatherstationname_position_offset uint32
var mcc_position_offset uint32
var mnc_position_offset uint32
var mobilebrand_position_offset uint32
var elevation_position_offset uint32
var usagetype_position_offset uint32

var country_enabled bool
var region_enabled bool
var city_enabled bool
var isp_enabled bool
var domain_enabled bool
var zipcode_enabled bool
var latitude_enabled bool
var longitude_enabled bool
var timezone_enabled bool
var netspeed_enabled bool
var iddcode_enabled bool
var areacode_enabled bool
var weatherstationcode_enabled bool
var weatherstationname_enabled bool
var mcc_enabled bool
var mnc_enabled bool
var mobilebrand_enabled bool
var elevation_enabled bool
var usagetype_enabled bool

// get IP type and calculate IP number; calculates index too if exists
func checkip(ip string) (iptype uint32, ipnum *big.Int, ipindex uint32) {
	iptype = 0
	ipnum = big.NewInt(0)
	ipnumtmp := big.NewInt(0)
	ipindex = 0
	ipaddress := net.ParseIP(ip)

	if ipaddress != nil {
		v4 := ipaddress.To4()

		if v4 != nil {
			iptype = 4
			ipnum.SetBytes(v4)
		} else {
			v6 := ipaddress.To16()

			if v6 != nil {
				iptype = 6
				ipnum.SetBytes(v6)
			}
		}
	}
	if iptype == 4 {
		fmt.Printf("==========>%v\n", ipnumtmp)
		if meta.ipv4indexbaseaddr > 0 {
			ipnumtmp.Rsh(ipnum, 16)
			fmt.Printf("==========>%v of ipnum=%d\n", ipnumtmp, ipnum)
			ipnumtmp.Lsh(ipnumtmp, 3)
			fmt.Printf("==========>%v\n", ipnumtmp)
			ipindex = uint32(ipnumtmp.Add(ipnumtmp, big.NewInt(int64(meta.ipv4indexbaseaddr))).Uint64())
			fmt.Printf("ipindex==========>%d\n", ipindex)
		}
	} else if iptype == 6 {
		if meta.ipv6indexbaseaddr > 0 {
			ipnumtmp.Rsh(ipnum, 112)
			ipnumtmp.Lsh(ipnumtmp, 3)
			ipindex = uint32(ipnumtmp.Add(ipnumtmp, big.NewInt(int64(meta.ipv6indexbaseaddr))).Uint64())
		}
	}
	return
}

// read byte
func readuint8(pos int64) uint8 {
	var retval uint8
	data := make([]byte, 1)
	_, err := f.ReadAt(data, pos-1)
	if err != nil {
		fmt.Println("File read failed:", err)
	}
	retval = data[0]
	return retval
}

// read unsigned 32-bit integer
func readuint32(pos uint32) uint32 {
	pos2 := int64(pos)
	var retval uint32
	data := make([]byte, 4)
	_, err := f.ReadAt(data, pos2-1)
	if err != nil {
		fmt.Println("File read failed:", err)
	}
	buf := bytes.NewReader(data)
	err = binary.Read(buf, binary.LittleEndian, &retval)
	if err != nil {
		fmt.Println("Binary read failed:", err)
	}
	return retval
}

// read unsigned 128-bit integer
func readuint128(pos uint32) *big.Int {
	pos2 := int64(pos)
	retval := big.NewInt(0)
	data := make([]byte, 16)
	_, err := f.ReadAt(data, pos2-1)
	if err != nil {
		fmt.Println("File read failed:", err)
	}

	// little endian to big endian
	for i, j := 0, len(data)-1; i < j; i, j = i+1, j-1 {
		data[i], data[j] = data[j], data[i]
	}
	retval.SetBytes(data)
	return retval
}

// read string
func readstr(pos uint32) string {
	pos2 := int64(pos)
	var retval string
	lenbyte := make([]byte, 1)
	_, err := f.ReadAt(lenbyte, pos2)
	if err != nil {
		fmt.Println("File read failed:", err)
	}
	strlen := lenbyte[0]
	data := make([]byte, strlen)
	_, err = f.ReadAt(data, pos2+1)
	if err != nil {
		fmt.Println("File read failed:", err)
	}
	retval = string(data[:strlen])
	return retval
}

// read float
func readfloat(pos uint32) float32 {
	pos2 := int64(pos)
	var retval float32
	data := make([]byte, 4)
	_, err := f.ReadAt(data, pos2-1)
	if err != nil {
		fmt.Println("File read failed:", err)
	}
	buf := bytes.NewReader(data)
	err = binary.Read(buf, binary.LittleEndian, &retval)
	if err != nil {
		fmt.Println("Binary read failed:", err)
	}
	return retval
}

// initialize the component with the database path
func Open(dbpath string) {
	max_ipv6_range.SetString("340282366920938463463374607431768211455", 10)

	var err error
	f, err = os.Open(dbpath)
	if err != nil {
		return
	}

	meta.databasetype = readuint8(1)
	meta.databasecolumn = readuint8(2)
	meta.databaseyear = readuint8(3)
	meta.databasemonth = readuint8(4)
	meta.databaseday = readuint8(5)
	meta.ipv4databasecount = readuint32(6)
	meta.ipv4databaseaddr = readuint32(10)
	meta.ipv6databasecount = readuint32(14)
	meta.ipv6databaseaddr = readuint32(18)
	meta.ipv4indexbaseaddr = readuint32(22)
	meta.ipv6indexbaseaddr = readuint32(26)
	meta.ipv4columnsize = uint32(meta.databasecolumn << 2)              // 4 bytes each column
	meta.ipv6columnsize = uint32(16 + ((meta.databasecolumn - 1) << 2)) // 4 bytes each column, except IPFrom column which is 16 bytes

	dbt := meta.databasetype

	// since both IPv4 and IPv6 use 4 bytes for the below columns, can just do it once here
	if country_position[dbt] != 0 {
		country_position_offset = uint32(country_position[dbt]-1) << 2
		country_enabled = true
	}
	if region_position[dbt] != 0 {
		region_position_offset = uint32(region_position[dbt]-1) << 2
		region_enabled = true
	}
	if city_position[dbt] != 0 {
		city_position_offset = uint32(city_position[dbt]-1) << 2
		city_enabled = true
	}
	if isp_position[dbt] != 0 {
		isp_position_offset = uint32(isp_position[dbt]-1) << 2
		isp_enabled = true
	}
	if domain_position[dbt] != 0 {
		domain_position_offset = uint32(domain_position[dbt]-1) << 2
		domain_enabled = true
	}
	if zipcode_position[dbt] != 0 {
		zipcode_position_offset = uint32(zipcode_position[dbt]-1) << 2
		zipcode_enabled = true
	}
	if latitude_position[dbt] != 0 {
		latitude_position_offset = uint32(latitude_position[dbt]-1) << 2
		latitude_enabled = true
	}
	if longitude_position[dbt] != 0 {
		longitude_position_offset = uint32(longitude_position[dbt]-1) << 2
		longitude_enabled = true
	}
	if timezone_position[dbt] != 0 {
		timezone_position_offset = uint32(timezone_position[dbt]-1) << 2
		timezone_enabled = true
	}
	if netspeed_position[dbt] != 0 {
		netspeed_position_offset = uint32(netspeed_position[dbt]-1) << 2
		netspeed_enabled = true
	}
	if iddcode_position[dbt] != 0 {
		iddcode_position_offset = uint32(iddcode_position[dbt]-1) << 2
		iddcode_enabled = true
	}
	if areacode_position[dbt] != 0 {
		areacode_position_offset = uint32(areacode_position[dbt]-1) << 2
		areacode_enabled = true
	}
	if weatherstationcode_position[dbt] != 0 {
		weatherstationcode_position_offset = uint32(weatherstationcode_position[dbt]-1) << 2
		weatherstationcode_enabled = true
	}
	if weatherstationname_position[dbt] != 0 {
		weatherstationname_position_offset = uint32(weatherstationname_position[dbt]-1) << 2
		weatherstationname_enabled = true
	}
	if mcc_position[dbt] != 0 {
		mcc_position_offset = uint32(mcc_position[dbt]-1) << 2
		mcc_enabled = true
	}
	if mnc_position[dbt] != 0 {
		mnc_position_offset = uint32(mnc_position[dbt]-1) << 2
		mnc_enabled = true
	}
	if mobilebrand_position[dbt] != 0 {
		mobilebrand_position_offset = uint32(mobilebrand_position[dbt]-1) << 2
		mobilebrand_enabled = true
	}
	if elevation_position[dbt] != 0 {
		elevation_position_offset = uint32(elevation_position[dbt]-1) << 2
		elevation_enabled = true
	}
	if usagetype_position[dbt] != 0 {
		usagetype_position_offset = uint32(usagetype_position[dbt]-1) << 2
		usagetype_enabled = true
	}

	metaok = true
}

// close database file handle
func Close() {
	f.Close()
}

// get api version
func Api_version() string {
	return api_version
}

// populate record with message
func loadmessage(mesg string) IP2Locationrecord {
	var x IP2Locationrecord

	x.Country_short = mesg
	x.Country_long = mesg
	x.Region = mesg
	x.City = mesg
	x.Isp = mesg
	x.Domain = mesg
	x.Zipcode = mesg
	x.Timezone = mesg
	x.Netspeed = mesg
	x.Iddcode = mesg
	x.Areacode = mesg
	x.Weatherstationcode = mesg
	x.Weatherstationname = mesg
	x.Mcc = mesg
	x.Mnc = mesg
	x.Mobilebrand = mesg
	x.Usagetype = mesg

	return x
}

// get all fields
func Get_all(ipaddress string) IP2Locationrecord {
	return query(ipaddress, all)
}

// get country code
func Get_country_short(ipaddress string) IP2Locationrecord {
	return query(ipaddress, countryshort)
}

// get country name
func Get_country_long(ipaddress string) IP2Locationrecord {
	return query(ipaddress, countrylong)
}

// get region
func Get_region(ipaddress string) IP2Locationrecord {
	return query(ipaddress, region)
}

// get city
func Get_city(ipaddress string) IP2Locationrecord {
	return query(ipaddress, city)
}

// get isp
func Get_isp(ipaddress string) IP2Locationrecord {
	return query(ipaddress, isp)
}

// get latitude
func Get_latitude(ipaddress string) IP2Locationrecord {
	return query(ipaddress, latitude)
}

// get longitude
func Get_longitude(ipaddress string) IP2Locationrecord {
	return query(ipaddress, longitude)
}

// get domain
func Get_domain(ipaddress string) IP2Locationrecord {
	return query(ipaddress, domain)
}

// get zip code
func Get_zipcode(ipaddress string) IP2Locationrecord {
	return query(ipaddress, zipcode)
}

// get time zone
func Get_timezone(ipaddress string) IP2Locationrecord {
	return query(ipaddress, timezone)
}

// get net speed
func Get_netspeed(ipaddress string) IP2Locationrecord {
	return query(ipaddress, netspeed)
}

// get idd code
func Get_iddcode(ipaddress string) IP2Locationrecord {
	return query(ipaddress, iddcode)
}

// get area code
func Get_areacode(ipaddress string) IP2Locationrecord {
	return query(ipaddress, areacode)
}

// get weather station code
func Get_weatherstationcode(ipaddress string) IP2Locationrecord {
	return query(ipaddress, weatherstationcode)
}

// get weather station name
func Get_weatherstationname(ipaddress string) IP2Locationrecord {
	return query(ipaddress, weatherstationname)
}

// get mobile country code
func Get_mcc(ipaddress string) IP2Locationrecord {
	return query(ipaddress, mcc)
}

// get mobile network code
func Get_mnc(ipaddress string) IP2Locationrecord {
	return query(ipaddress, mnc)
}

// get mobile carrier brand
func Get_mobilebrand(ipaddress string) IP2Locationrecord {
	return query(ipaddress, mobilebrand)
}

// get elevation
func Get_elevation(ipaddress string) IP2Locationrecord {
	return query(ipaddress, elevation)
}

// get usage type
func Get_usagetype(ipaddress string) IP2Locationrecord {
	return query(ipaddress, usagetype)
}

// main query
func query(ipaddress string, mode uint32) IP2Locationrecord {
	x := loadmessage(not_supported) // default message

	// read metadata
	if !metaok {
		x = loadmessage(missing_file)
		return x
	}

	// check IP type and return IP number & index (if exists)
	iptype, ipno, ipindex := checkip(ipaddress)

	if iptype == 0 {
		x = loadmessage(invalid_address)
		return x
	}

	var colsize uint32
	var baseaddr uint32
	var low uint32
	var high uint32
	var mid uint32
	var rowoffset uint32
	var rowoffset2 uint32
	ipfrom := big.NewInt(0)
	ipto := big.NewInt(0)
	maxip := big.NewInt(0)

	if iptype == 4 {
		baseaddr = meta.ipv4databaseaddr
		high = meta.ipv4databasecount
		maxip = max_ipv4_range
		colsize = meta.ipv4columnsize
		fmt.Printf("base: %d, high:%d, maxip:%d, colsize:%d\n", ipindex, high, maxip, colsize)
	} else {
		baseaddr = meta.ipv6databaseaddr
		high = meta.ipv6databasecount
		maxip = max_ipv6_range
		colsize = meta.ipv6columnsize
	}

	// reading index
	if ipindex > 0 {
		low = readuint32(ipindex)
		high = readuint32(ipindex + 4)
	}
	fmt.Printf("LOW=%d, HIGH=%d\n", low, high)

	if ipno.Cmp(maxip) >= 0 {
		ipno = ipno.Sub(ipno, big.NewInt(1))
	}

	for low <= high {
		mid = ((low + high) >> 1)
		rowoffset = baseaddr + (mid * colsize)
		rowoffset2 = rowoffset + colsize

		if iptype == 4 {
			ipfrom = big.NewInt(int64(readuint32(rowoffset)))
			ipto = big.NewInt(int64(readuint32(rowoffset2)))
		} else {
			ipfrom = readuint128(rowoffset)
			ipto = readuint128(rowoffset2)
		}

		if ipno.Cmp(ipfrom) >= 0 && ipno.Cmp(ipto) < 0 {
			if iptype == 6 {
				rowoffset = rowoffset + 12 // coz below is assuming all columns are 4 bytes, so got 12 left to go to make 16 bytes total
			}

			if mode&countryshort == 1 && country_enabled {
				x.Country_short = readstr(readuint32(rowoffset + country_position_offset))
			}

			if mode&countrylong != 0 && country_enabled {
				x.Country_long = readstr(readuint32(rowoffset+country_position_offset) + 3)
			}

			if mode&region != 0 && region_enabled {
				x.Region = readstr(readuint32(rowoffset + region_position_offset))
			}

			if mode&city != 0 && city_enabled {
				fmt.Printf("rowoffset == %d, city_position_offset == %d\n", rowoffset, city_position_offset)
				x.City = readstr(readuint32(rowoffset + city_position_offset))
			}

			if mode&isp != 0 && isp_enabled {
				x.Isp = readstr(readuint32(rowoffset + isp_position_offset))
			}

			if mode&latitude != 0 && latitude_enabled {
				x.Latitude = readfloat(rowoffset + latitude_position_offset)
			}

			if mode&longitude != 0 && longitude_enabled {
				x.Longitude = readfloat(rowoffset + longitude_position_offset)
			}

			if mode&domain != 0 && domain_enabled {
				x.Domain = readstr(readuint32(rowoffset + domain_position_offset))
			}

			if mode&zipcode != 0 && zipcode_enabled {
				x.Zipcode = readstr(readuint32(rowoffset + zipcode_position_offset))
			}

			if mode&timezone != 0 && timezone_enabled {
				x.Timezone = readstr(readuint32(rowoffset + timezone_position_offset))
			}

			if mode&netspeed != 0 && netspeed_enabled {
				x.Netspeed = readstr(readuint32(rowoffset + netspeed_position_offset))
			}

			if mode&iddcode != 0 && iddcode_enabled {
				x.Iddcode = readstr(readuint32(rowoffset + iddcode_position_offset))
			}

			if mode&areacode != 0 && areacode_enabled {
				x.Areacode = readstr(readuint32(rowoffset + areacode_position_offset))
			}

			if mode&weatherstationcode != 0 && weatherstationcode_enabled {
				x.Weatherstationcode = readstr(readuint32(rowoffset + weatherstationcode_position_offset))
			}

			if mode&weatherstationname != 0 && weatherstationname_enabled {
				x.Weatherstationname = readstr(readuint32(rowoffset + weatherstationname_position_offset))
			}

			if mode&mcc != 0 && mcc_enabled {
				x.Mcc = readstr(readuint32(rowoffset + mcc_position_offset))
			}

			if mode&mnc != 0 && mnc_enabled {
				x.Mnc = readstr(readuint32(rowoffset + mnc_position_offset))
			}

			if mode&mobilebrand != 0 && mobilebrand_enabled {
				x.Mobilebrand = readstr(readuint32(rowoffset + mobilebrand_position_offset))
			}

			if mode&elevation != 0 && elevation_enabled {
				f, _ := strconv.ParseFloat(readstr(readuint32(rowoffset+elevation_position_offset)), 32)
				x.Elevation = float32(f)
			}

			if mode&usagetype != 0 && usagetype_enabled {
				x.Usagetype = readstr(readuint32(rowoffset + usagetype_position_offset))
			}

			return x
		} else {
			if ipno.Cmp(ipfrom) < 0 {
				high = mid - 1
			} else {
				low = mid + 1
			}
		}
	}
	return x
}

// for debugging purposes
func Printrecord(x IP2Locationrecord) {
	fmt.Printf("country_short: %s\n", x.Country_short)
	fmt.Printf("country_long: %s\n", x.Country_long)
	fmt.Printf("region: %s\n", x.Region)
	fmt.Printf("city: %s\n", x.City)
	fmt.Printf("isp: %s\n", x.Isp)
	fmt.Printf("latitude: %f\n", x.Latitude)
	fmt.Printf("longitude: %f\n", x.Longitude)
	fmt.Printf("domain: %s\n", x.Domain)
	fmt.Printf("zipcode: %s\n", x.Zipcode)
	fmt.Printf("timezone: %s\n", x.Timezone)
	fmt.Printf("netspeed: %s\n", x.Netspeed)
	fmt.Printf("iddcode: %s\n", x.Iddcode)
	fmt.Printf("areacode: %s\n", x.Areacode)
	fmt.Printf("weatherstationcode: %s\n", x.Weatherstationcode)
	fmt.Printf("weatherstationname: %s\n", x.Weatherstationname)
	fmt.Printf("mcc: %s\n", x.Mcc)
	fmt.Printf("mnc: %s\n", x.Mnc)
	fmt.Printf("mobilebrand: %s\n", x.Mobilebrand)
	fmt.Printf("elevation: %f\n", x.Elevation)
	fmt.Printf("usagetype: %s\n", x.Usagetype)
}

func init() {
	Open("./IP-COUNTRY-REGION-CITY.BIN")
}

func GetIPLoc(ip string) {
	results := Get_all(ip)

	fmt.Printf("country_short: %s\n", results.Country_short)
	fmt.Printf("country_long: %s\n", results.Country_long)
	fmt.Printf("region: %s\n", results.Region)
	fmt.Printf("city: %s\n", results.City)
	fmt.Printf("isp: %s\n", results.Isp)
	fmt.Printf("latitude: %f\n", results.Latitude)
	fmt.Printf("longitude: %f\n", results.Longitude)
	fmt.Printf("domain: %s\n", results.Domain)
	fmt.Printf("zipcode: %s\n", results.Zipcode)
	fmt.Printf("timezone: %s\n", results.Timezone)
	fmt.Printf("netspeed: %s\n", results.Netspeed)
	fmt.Printf("iddcode: %s\n", results.Iddcode)
	fmt.Printf("areacode: %s\n", results.Areacode)
	fmt.Printf("weatherstationcode: %s\n", results.Weatherstationcode)
	fmt.Printf("weatherstationname: %s\n", results.Weatherstationname)
	fmt.Printf("mcc: %s\n", results.Mcc)
	fmt.Printf("mnc: %s\n", results.Mnc)
	fmt.Printf("mobilebrand: %s\n", results.Mobilebrand)
	fmt.Printf("elevation: %f\n", results.Elevation)
	fmt.Printf("usagetype: %s\n", results.Usagetype)
	fmt.Printf("meta version: %v\n", meta)
}
