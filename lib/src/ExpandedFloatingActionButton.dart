import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
///Custom CallBack Function to get the value of the pressed buttons` id
typedef OnSecondaryButtonClick = Function(int);

class CustomExpandedFab extends StatefulWidget {
  ///The main FAB button`s icon in normal mode
  final Icon mainButtonIcon;
  ///The main FAB button`s icon which will be displayed after the expansion
  final Icon? mainButtonExpandedIcon;
  ///The main FAB button`s background color
  final Color? mainButtonBackgroundColor;
  ///The main FAB button`s size
  final double? mainButtonSize;
  ///The main FAB button`s elevation (shadow below)
  final double? mainButtonElevation;
  ///This list of the action buttons that will be displayed in the expansion
  final List<SecondaryExpandedButton> secondaryButtons;
  ///On secondary button pressed will return the value of it
  final OnSecondaryButtonClick onSecondaryButtonClick;
  const CustomExpandedFab(
      {Key? key,
      required this.mainButtonIcon,
      this.mainButtonBackgroundColor,
      this.mainButtonSize,
      this.mainButtonElevation,
      required this.onSecondaryButtonClick,
      this.mainButtonExpandedIcon,
      required this.secondaryButtons})
      : super(key: key);
  @override
  _CustomExpandedFabState createState() => _CustomExpandedFabState();
}

class _CustomExpandedFabState extends State<CustomExpandedFab>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  ///[_start] flag to fire the animation on state change
  bool _start = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ///Use theme of the app in case of background not provided
    final ThemeData themeData = Theme.of(context);
    ///Check whether the buttons` id is duplicated or not to make sure that every button has it`s own id (Check it`s implementations below)
    _checkWidgetValidation();
    ///
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        FadeTransition(
          child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: widget.secondaryButtons
                  .map((button) =>
                  ///Mapping the buttons from the list secondaryButtons into a Floating Action Button
                  ///Using Animated Container to animate the buttons in a sequence with fade in/out animation
                  AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(
                            bottom: _start
                                ? (widget.secondaryButtons.indexOf(button) +
                                        1) *
                                    60.0
                                : 0.0),
                        child: FloatingActionButton(
                          onPressed: widget.onSecondaryButtonClick(button.id),
                          child: button.icon,
                          backgroundColor:
                              button.backgroundColor ?? themeData.accentColor,
                        ),
                      ))
                  .toList()),
          opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
        ),
        ///Using [RotationTransition] to animate the main button`s icon rotation
        RotationTransition(
          turns: Tween(begin: -1.0, end: -0.5).animate(_animationController),
          child: _MainButton(
            mainButtonSize: widget.mainButtonSize!,
            mainButtonIcon: widget.mainButtonIcon,
            mainButtonExpandedIcon: widget.mainButtonExpandedIcon!,
            mainButtonBackgroundColor: widget.mainButtonBackgroundColor!,
            animation: _animation,
            animationController: _animationController,
            mainButtonElevation: widget.mainButtonElevation!,
            onPress: () {
              setState(() {
                _start = !_start;
              });
            },
          ),
        ),
      ],
    );
  }

  ///function to check whether the buttons` id is valid or not
  void _checkWidgetValidation() {
    List<SecondaryExpandedButton> buttons = widget.secondaryButtons;
    for (int i = 0; i < buttons.length; i++) {
      for (int j = i + 1; j < buttons.length; j++) {
        if (buttons[i].id == buttons[j].id) {
          print("Same ${buttons[i].id}");
          throw ("(Expanded FAB) \nSorry You cannot use the same id for multi buttons.\nthe id (${buttons[i].id}) is duplicated");
        }
      }
    }
  }
}
///The Main FAB
class _MainButton extends StatelessWidget {
  final Icon? mainButtonIcon;
  final Icon? mainButtonExpandedIcon;
  final Color? mainButtonBackgroundColor;
  final double? mainButtonSize;
  final double? mainButtonElevation;
  final AnimationController? animationController;
  final Animation? animation;
  final VoidCallback? onPress;
  const _MainButton(
      {Key? key,
      this.mainButtonIcon,
      this.mainButtonBackgroundColor,
      this.mainButtonSize,
      this.mainButtonElevation,
      this.mainButtonExpandedIcon,
      this.animation,
      this.onPress,
      this.animationController})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FloatingActionButton(
        backgroundColor: mainButtonBackgroundColor,
        child: animation!.value <= 0.5
            ? Icon(
                mainButtonExpandedIcon != null
                    ? mainButtonExpandedIcon!.icon
                    : Icons.close,
                size: mainButtonIcon!.size,
                color: mainButtonIcon!.color,
              )
            : mainButtonIcon!,
        elevation: mainButtonElevation,
        onPressed: () {
          onPress!();
          if (animationController!.view.value == 1.0)
            animationController!.reverse();
          else
            animationController!.forward();
        },
      ),
      width: mainButtonSize,
      height: mainButtonSize,
    );
  }
}

class SecondaryExpandedButton extends StatelessWidget {
  final Color? backgroundColor;
  final double? size;
  final Icon icon;
  final int id;
  final VoidCallback? onPressed;
  const SecondaryExpandedButton(
      {Key? key,
      this.backgroundColor,
      this.size,
      required this.icon,
      required this.id,
      this.onPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: backgroundColor,
      child: icon,
      onPressed: onPressed,
    );
  }
}
