import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationBearingSection extends StatefulWidget {
  final LatLng? initialLocation;
  final double? initialBearing;
  final bool isPinned;
  final Function(LatLng) onLocationChanged;
  final Function(double) onBearingChanged;
  final VoidCallback onPin;
  final VoidCallback onUnpin;

  const LocationBearingSection({
    super.key,
    this.initialLocation,
    this.initialBearing,
    required this.isPinned,
    required this.onLocationChanged,
    required this.onBearingChanged,
    required this.onPin,
    required this.onUnpin,
  });

  @override
  State<LocationBearingSection> createState() => _LocationBearingSectionState();
}

class _LocationBearingSectionState extends State<LocationBearingSection> {
  late GoogleMapController _mapController;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Map Container
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation ?? 
                    const LatLng(1.3521, 103.8198), // Singapore coordinates
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() => _isInitialized = true);
              },
              onCameraMove: (position) {
                if (!widget.isPinned) {
                  widget.onLocationChanged(position.target);
                }
              },
              markers: widget.initialLocation == null ? {} : {
                Marker(
                  markerId: const MarkerId('location'),
                  position: widget.initialLocation!,
                ),
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Bearing Controls
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.isPinned ? widget.onUnpin : widget.onPin,
                icon: Icon(widget.isPinned ? Icons.lock_open : Icons.lock),
                label: Text(widget.isPinned ? 'Unpin Location' : 'Pin Location & Bearing'),
              ),
            ),
          ],
        ),
        
        if (widget.initialBearing != null) ...[
          const SizedBox(height: 8),
          Text(
            'Current Bearing: ${widget.initialBearing!.toStringAsFixed(2)}°',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}