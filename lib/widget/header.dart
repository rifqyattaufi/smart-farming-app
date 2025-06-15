import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

enum HeaderType { basic, menu, back }

enum IconType { svg, image }

class Header extends StatefulWidget {
  final HeaderType headerType;
  final String? title;
  final String? greeting;
  final String? leadingIconPath;
  final IconType? leadingIconType;

  const Header({
    super.key,
    required this.headerType,
    this.title,
    this.greeting,
    this.leadingIconPath,
    this.leadingIconType,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final AuthService _authService = AuthService();
  String? _title;
  String? _greeting;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    // _title = widget.title;
    // _greeting = widget.greeting;

    if (widget.title == null) {
      _authService.getUser().then((user) {
        if (user != null) {
          setState(() {
            _greeting = 'Halo, ${user['name']} 👋';
            _title = _getTitleBasedOnRole(user['role']);
            _profilePictureUrl = user['avatar'];
          });
        }
      });
    }
  }

  String _getTitleBasedOnRole(String role) {
    switch (role) {
      case 'pjawab':
        return 'Penanggung Jawab RFC';
      case 'inventor':
        return 'Inventor';
      case 'petugas':
        return 'Petugas RFC';
      default:
        return 'Pengguna';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.headerType == HeaderType.basic) ...[
                ClipOval(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: ImageBuilder(
                      url: _profilePictureUrl ?? 'assets/images/user.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (widget.headerType == HeaderType.back) ...[
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    key: const Key('backButton'),
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: dark1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                padding: EdgeInsets.only(
                  left: widget.headerType == HeaderType.back ? 0 : 16,
                  right: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? _title ?? '',
                      style: regular12.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.greeting ?? _greeting ?? '',
                      style: semibold20.copyWith(color: dark1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.headerType == HeaderType.basic) ...[
            GestureDetector(
              onTap: () {
                context.push('/notifikasi');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: green3,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/icons/bell.svg',
                  colorFilter: ColorFilter.mode(green1, BlendMode.srcIn),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
