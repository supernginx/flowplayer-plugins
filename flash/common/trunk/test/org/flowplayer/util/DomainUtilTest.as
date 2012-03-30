/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.util {
    import flexunit.framework.TestCase;

    public class DomainUtilTest extends TestCase {

        public function test1():void {
            assertEquals("foo.on.ca", DomainUtil.stripSubdomain("foo.on.ca"));
        }

        public function test2():void {
            assertEquals("xx.foobar", DomainUtil.stripSubdomain("jee.xx.foobar"));
        }

        public function testStripSubdomain():void {
            assertEquals("foobar", DomainUtil.stripSubdomain("foobar"));
            assertEquals("foobar.com", DomainUtil.stripSubdomain("foobar.com"));
            assertEquals("foobar.com", DomainUtil.stripSubdomain("foo.foobar.com"));

            assertEquals("carleton.ca", DomainUtil.stripSubdomain("foo.carleton.ca"));
            assertEquals("blacksun.us.com", DomainUtil.stripSubdomain("blacksun.us.com"));
            assertEquals("blacksun.us.com", DomainUtil.stripSubdomain("www.blacksun.us.com"));

            /*
             * Test cases from http://publicsuffix.org/list/test.txt
             */
//            checkPublicSuffix(null, null);
//# Mixed case.
//            checkPublicSuffix('COM', null);
            assertEquals('example.com', DomainUtil.stripSubdomain('example.com'));
//            checkPublicSuffix('WwW.example.COM', 'example.com');
//# Unlisted TLD.
            assertEquals('example', DomainUtil.stripSubdomain('example'));
            assertEquals('example.example', DomainUtil.stripSubdomain('example.example'));
            assertEquals('example.example', DomainUtil.stripSubdomain('b.example.example'));
            assertEquals('example.example', DomainUtil.stripSubdomain('a.b.example.example'));
            assertEquals('0.128', DomainUtil.stripSubdomain('194.215.0.128'));
//# TLD with only 1 rule.
//            checkPublicSuffix('biz', null);
            assertEquals('domain.biz', DomainUtil.stripSubdomain('domain.biz'));
            assertEquals('domain.biz', DomainUtil.stripSubdomain('b.domain.biz'));
            assertEquals('domain.biz', DomainUtil.stripSubdomain('a.b.domain.biz'));
//# TLD with some 2-level rules.
//            checkPublicSuffix('com', null);
            assertEquals('example.com', DomainUtil.stripSubdomain('example.com'));
            assertEquals('example.com', DomainUtil.stripSubdomain('b.example.com'));
            assertEquals('example.com', DomainUtil.stripSubdomain('a.b.example.com'));
//            checkPublicSuffix('uk.com', null);
            assertEquals('example.uk.com', DomainUtil.stripSubdomain('example.uk.com'));
            assertEquals('example.uk.com', DomainUtil.stripSubdomain('b.example.uk.com'));
            assertEquals('example.uk.com', DomainUtil.stripSubdomain('a.b.example.uk.com'));
            assertEquals('test.ac', DomainUtil.stripSubdomain('test.ac'));
//# TLD with only 1 (wildcard) rule.
//            checkPublicSuffix('cy', null);
//            checkPublicSuffix('c.cy', null);
//            checkPublicSuffix('b.c.cy', 'b.c.cy');
//            checkPublicSuffix('a.b.c.cy', 'b.c.cy');
//# More complex TLD.
//            checkPublicSuffix('jp', null);
//            checkPublicSuffix('test.jp', 'test.jp');
//            checkPublicSuffix('www.test.jp', 'test.jp');
////            checkPublicSuffix('ac.jp', null);
//            checkPublicSuffix('test.ac.jp', 'test.ac.jp');
//            checkPublicSuffix('www.test.ac.jp', 'test.ac.jp');
////            checkPublicSuffix('kyoto.jp', null);
////            checkPublicSuffix('c.kyoto.jp', null);
//            checkPublicSuffix('b.c.kyoto.jp', 'b.c.kyoto.jp');
//            checkPublicSuffix('a.b.c.kyoto.jp', 'b.c.kyoto.jp');
//            checkPublicSuffix('pref.kyoto.jp', 'pref.kyoto.jp');	// # Exception rule.
//            checkPublicSuffix('www.pref.kyoto.jp', 'pref.kyoto.jp');	// # Exception rule.
//            checkPublicSuffix('city.kyoto.jp', 'city.kyoto.jp');	// # Exception rule.
//            checkPublicSuffix('www.city.kyoto.jp', 'city.kyoto.jp');	// # Exception rule.
////# TLD with a wildcard rule and exceptions.
////            checkPublicSuffix('om', null);
////            checkPublicSuffix('test.om', null);
//            checkPublicSuffix('b.test.om', 'b.test.om');
//            checkPublicSuffix('a.b.test.om', 'b.test.om');
//            checkPublicSuffix('songfest.om', 'songfest.om');
//            checkPublicSuffix('www.songfest.om', 'songfest.om');
//
////            checkPublicSuffix('us', null);
//            checkPublicSuffix('test.us', 'test.us');
//            checkPublicSuffix('www.test.us', 'test.us');
////            checkPublicSuffix('ak.us', null);
//            checkPublicSuffix('test.ak.us', 'test.ak.us');
//            checkPublicSuffix('www.test.ak.us', 'test.ak.us');
////# US K12.
////            checkPublicSuffix('us', null);
//            checkPublicSuffix('test.us', 'test.us');
//            checkPublicSuffix('www.test.us', 'test.us');
////            checkPublicSuffix('ak.us', null);
//            checkPublicSuffix('test.ak.us', 'test.ak.us');
//            checkPublicSuffix('www.test.ak.us', 'test.ak.us');
////            checkPublicSuffix('k12.ak.us', null);
//            checkPublicSuffix('test.k12.ak.us', 'test.k12.ak.us');
//            checkPublicSuffix('www.test.k12.ak.us', 'test.k12.ak.us');
//
//            // misc
//            checkPublicSuffix(' www.pss3.home.pl', 'home.pl');
//            checkPublicSuffix(' xxx.ais5.pl', 'ais5.pl');
        }

        public function testMisc():void {
            assertEquals('home.pl', DomainUtil.stripSubdomain(' www.pss3.home.pl'));
            assertEquals('ais5.pl', DomainUtil.stripSubdomain(' xxx.ais5.pl'));
        }

        public function testParseDomain():void {
            assertEquals("amexinsite.com", DomainUtil.parseDomain('https://home.amexinsite.com/insite_video.htm', true));
        }

        public function testIPAddressDomain():void {
            trace(DomainUtil.parseDomain('123.123.123.64', true));
            assertEquals("123.64", DomainUtil.parseDomain('123.123.123.64', true));
        }

        public function testIPAddressDomain2():void {
            assertEquals("123.64", DomainUtil.parseDomain('123.123.64', true));
        }

        public function testIPAddressDomain3():void {
            assertEquals("123.64", DomainUtil.parseDomain('123.64', true));
        }

        public function testInternalDomain():void {
            assertEquals("foobar", DomainUtil.parseDomain('foobar', true));
        }
    }
}
